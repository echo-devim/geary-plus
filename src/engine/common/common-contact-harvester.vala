/*
 * Copyright 2016 Software Freedom Conservancy Inc.
 * Copyright 2019 Michael Gratton <mike@vee.net>
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later). See the COPYING file in this distribution.
 */

/** Denotes objects that extract contacts from email meages. */
internal interface Geary.ContactHarvester : GLib.Object {

    public abstract async void harvest_from_email(Gee.Collection<Email> messages,
                                                  GLib.Cancellable? cancellable)
        throws GLib.Error;

}

/** Default harvester that saves contacts in the contact store. */
internal class Geary.ContactHarvesterImpl : BaseObject, ContactHarvester {

    private const Email.Field REQUIRED_FIELDS = ORIGINATORS | RECEIVERS;

    private const SpecialFolderType[] FOLDER_WHITELIST = {
        INBOX,
        ARCHIVE,
        SENT,
        NONE
    };


    private ContactStore store;
    private Gee.Collection<RFC822.MailboxAddress> owner_mailboxes;
    private SpecialFolderType location;
    private bool is_whitelisted;

    public ContactHarvesterImpl(ContactStore store,
                                SpecialFolderType location,
                                Gee.Collection<RFC822.MailboxAddress> owners) {
        this.store = store;
        this.owner_mailboxes = owners;
        this.location = location;
        this.is_whitelisted = (location in FOLDER_WHITELIST);
    }

    public async void harvest_from_email(Gee.Collection<Email> messages,
                                         GLib.Cancellable? cancellable)
        throws GLib.Error {
        if (this.is_whitelisted && !messages.is_empty) {
            Gee.Map<string,Contact> contacts = new Gee.HashMap<string,Contact>();
            int importance = Contact.Importance.SEEN;
            if (this.location == SENT) {
                importance = Contact.Importance.SENT_TO;
            }
            Email.Field type = 0;
            foreach (Email message in messages) {
                if (message.fields.fulfills(REQUIRED_FIELDS)) {
                    type = Email.Field.ORIGINATORS;
                    add_contacts(contacts, message.from, type, importance);
                    if (message.sender != null) {
                        add_contact(contacts, message.sender, type, importance);
                    }
                    add_contacts(contacts, message.bcc, type, importance);

                    type = Email.Field.RECEIVERS;
                    add_contacts(contacts, message.to, type, importance);
                    add_contacts(contacts, message.cc, type, importance);
                    add_contacts(contacts, message.bcc, type, importance);
                }
            }

            yield this.store.update_contacts(contacts.values, cancellable);
        }
    }

    private void add_contacts(Gee.Map<string, Contact> contacts,
                              RFC822.MailboxAddresses? addresses,
                              Email.Field type,
                              int importance) {
        if (addresses != null) {
            foreach (RFC822.MailboxAddress address in addresses) {
                add_contact(contacts, address, type, importance);
            }
        }
    }

    private inline void add_contact(Gee.Map<string, Contact> contacts,
                                    RFC822.MailboxAddress address,
                                    Email.Field type,
                                    int importance) {
        if (address.is_valid() && !address.is_spoofed()) {
            if (type == RECEIVERS && address in this.owner_mailboxes) {
                importance = Contact.Importance.RECEIVED_FROM;
            }

            Contact contact = new Contact.from_rfc822_address(
                address, importance
            );
            Contact? existing = contacts[contact.normalized_email];
            if (existing == null ||
                existing.highest_importance < contact.highest_importance) {
                contacts[contact.normalized_email] = contact;
            }
        }
    }

}
