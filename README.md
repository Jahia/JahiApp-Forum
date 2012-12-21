JahiApp Forum
=============

Installation
------------

In the modules/META-INF/spring/modforum-xml change the following settings:

    <property name="templatePath" value="/META-INF/mails/templates/postAdded.vm"/>
    <property name="toAdministratorMail" value="false"/>
    <property name="email_from" value="from@jahia.com"/>
    <property name="email_to" value="to@jahia.com"/>
    <property name="sendNotificationsToContributors" value="true"/>
    <property name="sendSpamNotificationsToAdministrator" value="true" />
    <property name="forumHostUrlPart" value="http://localhost:8080"/>

You should change the following settings : email_form, email_to and forumHostUrlPart at a minimum.

It is also recommended that you install the following module : https://github.com/shyrkov/jahia-spam-filtering

