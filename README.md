
Geary Plus: Send and receive email
=============================

![Geary icon](https://wiki.gnome.org/Apps/Geary?action=AttachFile&do=get&target=geary-3-32-256-logo.png)

Geary is an email application built around conversations, for the
GNOME 3 desktop. It allows you to read, find and send email with a
straightforward, modern interface.

Visit https://wiki.gnome.org/Apps/Geary for more information.

**GitHub users please note**: Contributions for Geary Plus are welcomed here on GitHub.

![Geary displaying a conversation](https://wiki.gnome.org/Apps/Geary?action=AttachFile&amp;do=get&amp;target=geary-3-32-main-window.png)

## Extra Features
Geary Plus has more features than Geary. Actually it has:
 * AntiSpam module

## AntiSpam
Geary Plus is born because Geary is too limited. It implements an AntiSpam module in order to delete emails containing forbidden words.

To activate the AntiSpam module create the file `~/.config/geary/antispam.conf` with the following content:
```
subject_blacklist=new offer for you|bank account|iban
message_blacklist=reset your facebook account|i hacked|new offer for you
senders_blacklist=imaspammer@spammer.com|foo@bar.com
action=trash
```
where it is possible to set forbidden words or sentences for three email fields:
 * Sender email name and address
 * Subject
 * Email body

You can set one or more tokens. In case you set more than one token, they must be separated by the `|` character.
If you don't want to set any forbidden word for a specific email field (e.g. the message) you can just remove its line from the configuration file.
The `action` is applied when one of the defined token **is contained** in the referred field.
The field `action` can have the following values:
 * *trash*: Move the email to the `Trash` special folder (default action if not specified)
 * *delete*: Delete the email (irreversible action)


Installation & Licensing
------------------------

Please consult the [INSTALL](./INSTALL) and [COPYING](./COPYING) files
for more information.

Getting in Touch
----------------

 * Geary wiki:   https://wiki.gnome.org/Apps/Geary
 * Mailing list: http://mail.gnome.org/mailman/listinfo/geary-list
 * IRC Channel:  [#geary on irc.gimp.org](irc://irc.gimp.org/%23geary)

**Code Of Conduct**

We follow the [Contributor Covenant](./code-of-conduct.md) as our
Code of Conduct. All communications in project spaces are expected to
follow it.

Contributing to Geary
---------------------

Want to help improve Geary? Here are some ways to contribute:

 * Bug reporting: https://wiki.gnome.org/Apps/Geary/ReportingABug
 * Development:   https://wiki.gnome.org/Apps/Geary/Development
 * Translating:   https://wiki.gnome.org/Apps/Geary/Translating
 * Join the mailing list or IRC channel and join in the discussion

---
Copyright 2016 Software Freedom Conservancy Inc.  
Copyright 2017 Michael Gratton <mike@vee.net>
