package org.jahia.modules.forum.rules;

import org.apache.commons.lang.StringUtils;
import org.apache.velocity.tools.generic.DateTool;
import org.apache.velocity.tools.generic.EscapeTool;
import org.drools.core.spi.KnowledgeHelper;
import org.jahia.bin.Jahia;
import org.jahia.registries.ServicesRegistry;
import org.jahia.services.content.JCRContentUtils;
import org.jahia.services.content.JCRNodeWrapper;
import org.jahia.services.content.rules.AddedNodeFact;
import org.jahia.services.content.rules.User;
import org.jahia.services.mail.MailService;
import org.jahia.services.usermanager.JahiaUser;
import org.jahia.services.usermanager.JahiaUserManagerService;
import org.jahia.settings.SettingsBean;
import org.jahia.utils.LanguageCodeConverters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jcr.RepositoryException;
import java.util.*;

/**
 * Backend rule service to implement rule consequences
 */
public class ForumRuleService {

    private static Logger logger = LoggerFactory.getLogger(ForumRuleService.class);

    private static final String SPAM_DETECTED_MIXIN = "jmix:spamFilteringSpamDetected";

    private MailService mailService;
    private String templatePath;
    private boolean toAdministratorMail;
    private boolean sendNotificationsToContributors;
    private String email_from;
    private String email_to;
    private String forumHostUrlPart;
    private boolean sendSpamNotificationsToAdministrator;
    private String administratorSpamNotificationEmail;

    public void setToAdministratorMail(boolean toAdministratorMail) {
        this.toAdministratorMail = toAdministratorMail;
    }

    public void setSendNotificationsToContributors(boolean sendNotificationsToContributors) {
        this.sendNotificationsToContributors = sendNotificationsToContributors;
    }

    public void setEmail_from(String email_from) {
        this.email_from = email_from;
    }

    public void setEmail_to(String email_to) {
        this.email_to = email_to;
    }

    public void setMailService(MailService mailService) {
        this.mailService = mailService;
    }

    public void setTemplatePath(String templatePath) {
        this.templatePath = templatePath;
    }

    public void setForumHostUrlPart(String forumHostUrlPart) {
        this.forumHostUrlPart = forumHostUrlPart;
    }

    public void setSendSpamNotificationsToAdministrator(boolean sendSpamNotificationsToAdministrator) {
        this.sendSpamNotificationsToAdministrator = sendSpamNotificationsToAdministrator;
    }

    public void setAdministratorSpamNotificationEmail(String administratorSpamNotificationEmail) {
        this.administratorSpamNotificationEmail = administratorSpamNotificationEmail;
    }

    public void sendNotificationToPosters(AddedNodeFact nodeFact, KnowledgeHelper drools) throws RepositoryException {
        if (!mailService.isEnabled()) {
            // mail service is not enabled -> skip sending notifications
            return;
        }
        if (logger.isDebugEnabled()) {
            logger.debug("Sending notification to posters of a new node {}", nodeFact.getPath());
        }

        try {
            boolean spamDetected = false;
            JCRNodeWrapper node = nodeFact.getNode();

            if (node.isNodeType(SPAM_DETECTED_MIXIN)) {
                spamDetected = true;
                logger.info("Content of the node {} is detected as spam, will not send notifications to contributors", node.getPath());
                if (sendSpamNotificationsToAdministrator) {
                    logger.info("Sending spam notification to administrator");
                }
            }

            User user = (User) drools.getWorkingMemory().getGlobal("user");

            List<String> emails = new ArrayList<String>();

            // Prepare mail to be sent :
            if ((spamDetected && sendSpamNotificationsToAdministrator) || (!spamDetected)) {
                String administratorEmail = toAdministratorMail ? mailService.getSettings().getTo() : email_to;
                if (spamDetected && StringUtils.isNotEmpty(administratorSpamNotificationEmail)) {
                    administratorEmail = administratorSpamNotificationEmail;
                }
                emails.add(administratorEmail);
            }

            Locale defaultLocale = null;
            if (node.getExistingLocales() != null &&
                    node.getExistingLocales().size() > 0) {
                defaultLocale = node.getExistingLocales().get(0);
            }
            if (defaultLocale == null) {
                defaultLocale = SettingsBean.getInstance().getDefaultLocale();
            }

            Map<String, Object> bindings = new HashMap<String, Object>();
            bindings.put("formNode", node.getParent());
            bindings.put("formNewNode", node);
            bindings.put("ParentFormNode", node.getParent().getParent());
            bindings.put("submitter", user);
            bindings.put("date", new DateTool());
            bindings.put("esc", new EscapeTool());
            bindings.put("submissionDate", Calendar.getInstance());
            bindings.put("spamDetected", spamDetected);
            bindings.put("formURL", forumHostUrlPart + Jahia.getContextPath() + node.getParent().getUrl());

            Map<String, Locale> preferredLocales = new HashMap<String, Locale>();

            if (sendNotificationsToContributors && !spamDetected) {
                // iterate the childs and get posts creator's emails
                List<JCRNodeWrapper> postList = JCRContentUtils.getChildrenOfType(node.getParent(), "jnt:post");
                Iterator<JCRNodeWrapper> postIterator = postList.iterator();
                JahiaUserManagerService userManager = ServicesRegistry.getInstance().getJahiaUserManagerService();

                String currentUser = user.getName();
                while (postIterator.hasNext()) {
                    JCRNodeWrapper post = postIterator.next();
                    String creator = post.getCreationUser();
                    String email = null;
                    if (creator != null) {
                        JahiaUser jahiaUser = userManager.lookupUser(creator);
                        if (user != null && !(creator).equals(currentUser)) {
                            boolean emailNotificationsDisabled = "true".equals(jahiaUser.getProperty("emailNotificationsDisabled"));
                            if (!emailNotificationsDisabled) {
                                email = jahiaUser.getProperty("j:email");
                                if (email != null && !emails.contains(email) && email.length() > 5) {
                                    emails.add(email);
                                    if (getPreferredLocale(jahiaUser) != null) {
                                        preferredLocales.put(email, getPreferredLocale(jahiaUser));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (emails.size() > 0) {
                Iterator<String> emailIterator = emails.iterator();
                while (emailIterator.hasNext()) {
                    String destinationEmail = emailIterator.next();
                    try {
                        Locale userLocale = defaultLocale;
                        if (preferredLocales.containsKey(destinationEmail)) {
                            userLocale = preferredLocales.get(destinationEmail);
                        }
                        bindings.put("locale", userLocale);
                        mailService.sendMessageWithTemplate(templatePath, bindings, destinationEmail, email_from, "", "", userLocale, "Jahia Forum");
                        logger.info("Post creation notification sent by e-mail to " + destinationEmail + " using locale " + userLocale);
                    } catch (Exception e) {
                        logger.info("Couldn't sent forum email notification: ", e);

                    }
                }
            }
        } catch (Exception e) {
            logger.warn("Unable to send notifications for new node " + nodeFact.getPath()
                    + " Cause: " + e.getMessage(), e);
        }

    }

    private Locale getPreferredLocale(JahiaUser userNode) {
        Locale locale = null;
        String property = userNode.getProperty("preferredLanguage");
        if (property != null) {
            locale = LanguageCodeConverters.languageCodeToLocale(property);
        }
        return locale;
    }

}
