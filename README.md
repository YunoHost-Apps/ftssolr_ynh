# ftssolr

Solr Full Text Search for dovecot

Thanks to :
http://wiki.dovecot.org/Plugins/FTS/Solr
https://blog.vbonhomme.fr/add-full-text-search-fts-to-your-dovecot-using-solr-4-10-on-ubuntu-14-04/
https://github.com/andryyy/mailcow

The first time you search inside one mailbox, dovecot will index it.
Subsequent searches will run blazingly faster.

To verify that everything is running fine :

    $ telnet localhost imap

    1 LOGIN <your_username> <your_password>
    2 SELECT Inbox
    3 SEARCH text "test"
    * OK Indexed 51% of the mailbox, ETA 0:09
    * OK Indexed 97% of the mailbox, ETA 0:00
    * OK Mailbox indexing finished
    * SEARCH [...]
    3 OK Search completed (27.633 secs).
    4 SEARCH text "test"
    * SEARCH [...]
    4 OK Search completed (0.013 secs).
    10 LOGOUT

Roundcube searches should be must faster.
You can enable the "Entire message" checkbox for full text search.

To use the Full Text Search capabilities of the IMAP server from Thunderbird (instead of using Thunderbird own index),
search your messages with Ctrl+Shift+F
