/** This class implements the AntiSpam module **/
public class AntiSpam : GLib.Object {

    private Gee.ArrayList<string> senders_blacklist = new Gee.ArrayList<string> ();
    private Gee.ArrayList<string> subject_blacklist = new Gee.ArrayList<string> ();
    private Gee.ArrayList<string> message_blacklist = new Gee.ArrayList<string> ();
    public string action = "trash";

    public AntiSpam() {
        // Load the forbidden wordlists from configuration file
        try {
            var file = File.new_for_path (GLib.Environment.get_home_dir() + "/.config/geary/antispam.conf");
    
            if (file.query_exists ()) {
                var dis = new DataInputStream (file.read ());
                string line;
    
                while ((line = dis.read_line (null)) != null) {
                    line = line.replace("\n", "");
                    line = line.replace("\r", "");
                    var topic = line.substring(0, 7);
                    if (topic == "subject") {
                        var key = "subject_blacklist";
                        var words = line.substring(key.length + 1); // +1 is for the '=' character
                        foreach (string word in words.split("|")) {
                            subject_blacklist.add(word);
                        }
                    } else if (topic == "message") {
                        var key = "message_blacklist";
                        var words = line.substring(key.length + 1);
                        foreach (string word in words.split("|")) {
                            message_blacklist.add(word);
                        }
                    } else if (topic == "senders") {
                        var key = "senders_blacklist";
                        var words = line.substring(key.length + 1);
                        foreach (string word in words.split("|")) {
                            senders_blacklist.add(word);
                        }
                    } else if (topic == "action") {
                        var key = "action";
                        action = line.substring(key.length + 1);
                    }
                }
    
            }
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
        }
    }

    public bool is_spam(Geary.Email email) {

        foreach (string keyword in senders_blacklist) {
            string sender = "";

            if (email.from != null) {
                sender = email.from.to_searchable_string();
            } else if (email.sender != null) {
                sender = email.sender.address;
            }

            if (sender.down().contains(keyword)) {
                //stdout.printf("Found forbidden sender email %s\n", sender);
                return true;
            }
        }

        foreach (string keyword in subject_blacklist) {
            if (email.subject.to_searchable_string().down().contains(keyword)) {
                //stdout.printf("Found forbidden keyword %s in email %s\n", keyword, email.subject.to_searchable_string());
                return true;
            }
        }

        foreach (string keyword in message_blacklist) {
            if (email.get_preview_as_string().down().contains(keyword)) {
                //stdout.printf("Found forbidden keyword %s in email text preview\n", keyword);
                return true;
            }
        }

        return false;
    }
}