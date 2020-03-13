JahiApp Forum
=============

This is a test branch

Installation
------------

Since version 1.6 it is now possible and recommended (to make upgrading easier) to setup the forum settings directly
from the jahia.properties file (or if you prefer jahia.custom.properties), using the following
parameters (default values are also given here) :

    # The following setting defines a path to a Velocity template used to format mail notifications to both administrators
    # and forum contributors
    forumMailNotificationTemplatePath   = /META-INF/mails/templates/postAdded.vm

    # The following setting controls whether the administrator notifications should be sent to the global Jahia administrator
    # of to the one configured in the forum's settings. If set to false all forum administration mail will be sent to the
    # email set in the forumAdministratorEmail setting, otherwise it will be sent to the email address of the Jahia
    # administrator (root) user.
    forumAlwaysNotifyAdministrator      = false

    # The following setting specifies the email address to use in the from: field of the emails being sent out.
    forumMailNotificationFrom           = from@jahia.com

    # The following setting specifies the destination email address for all the forum administration emails. The forum
    # administrator receives a copy of all the messages being posted in the forum or in blog posts.
    forumAdministratorEmail             = to@jahia.com

    # If activated the following setting will send notifications to all the contributors in a forum subject or all the
    # comment on a blog post. Leaving this activated is recommended as it will help with the community building and should
    # be acceptable in terms of traffic. For the moment there is no way for the contributors to control this (opt-out) on
    # a subject or blog article basis, but their email notification setting will be honored.
    forumSendNotificationToContributors = true

    # If activated, the following setting will send spam notification to the forum administrator, using the
    # forumAdministratorSpamEmail address if specified, or his default email address if no specific spam email address
    # was setup.
    forumSpamNotificationsToAdmin       = true

    # The following setting is used to build absolute links to the forum posts inside the notification emails. This setting
    # is especially useful if you are using some kind of web front-end in front of your Jahia installation that might to
    # strange things with the domain name or simply redirect traffic to another port.
    forumHostUrlPart                    = http://localhost:8080

    # The following setting is used to use a different email address for spam notification, instead of using the default
    # administrator email address to prevent spamming administrators with spam notifications.
    forumAdministratorSpamEmail         = forum-spam@jahia.com

You will have to add these parameters in the jahia.properties file as they are not present by default.

You should change the following settings : forumMailNotificationFrom, forumAdministratorEmail and forumHostUrlPart
at a minimum.

It is also recommended that you install the following module : https://github.com/Jahia/jahia-spam-filtering
This module will integrate with the Akismet spam detection service to detect and blacklist spam messages.

