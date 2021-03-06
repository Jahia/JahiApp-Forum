/*
 * ==========================================================================================
 * =                   JAHIA'S DUAL LICENSING - IMPORTANT INFORMATION                       =
 * ==========================================================================================
 *
 *                                 http://www.jahia.com
 *
 *     Copyright (C) 2002-2020 Jahia Solutions Group SA. All rights reserved.
 *
 *     THIS FILE IS AVAILABLE UNDER TWO DIFFERENT LICENSES:
 *     1/GPL OR 2/JSEL
 *
 *     1/ GPL
 *     ==================================================================================
 *
 *     IF YOU DECIDE TO CHOOSE THE GPL LICENSE, YOU MUST COMPLY WITH THE FOLLOWING TERMS:
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *     2/ JSEL - Commercial and Supported Versions of the program
 *     ===================================================================================
 *
 *     IF YOU DECIDE TO CHOOSE THE JSEL LICENSE, YOU MUST COMPLY WITH THE FOLLOWING TERMS:
 *
 *     Alternatively, commercial and supported versions of the program - also known as
 *     Enterprise Distributions - must be used in accordance with the terms and conditions
 *     contained in a separate written agreement between you and Jahia Solutions Group SA.
 *
 *     If you are unsure which license is appropriate for your use,
 *     please contact the sales department at sales@jahia.com.
 */
package org.jahia.modules.forum.rules;

import org.apache.commons.lang.StringUtils;
import org.apache.velocity.tools.generic.DateTool;
import org.apache.velocity.tools.generic.EscapeTool;
import org.drools.core.spi.KnowledgeHelper;
import org.jahia.registries.ServicesRegistry;
import org.jahia.services.content.JCRContentUtils;
import org.jahia.services.content.JCRNodeWrapper;
import org.jahia.services.content.decorator.JCRUserNode;
import org.jahia.services.content.rules.AddedNodeFact;
import org.jahia.services.content.rules.User;
import org.jahia.services.mail.MailService;
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
            bindings.put("formURL", forumHostUrlPart + node.getParent().getUrl());

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
                    String email;
                    if (creator != null) {
                        JCRUserNode jahiaUser = userManager.lookupUser(creator);
                        if (jahiaUser != null && !(creator).equals(currentUser)) {
                            boolean emailNotificationsDisabled = "true".equals(jahiaUser.getPropertyAsString("emailNotificationsDisabled"));
                            if (!emailNotificationsDisabled) {
                                email = jahiaUser.getPropertyAsString("j:email");
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
            if (!emails.isEmpty()) {
                for (String destinationEmail : emails) {
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

    private Locale getPreferredLocale(JCRUserNode userNode) throws RepositoryException {
        Locale locale = null;
        String property = userNode.getPropertyAsString("preferredLanguage");
        if (property != null) {
            locale = LanguageCodeConverters.languageCodeToLocale(property);
        }
        return locale;
    }

}
