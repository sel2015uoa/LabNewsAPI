class Api::V1::MailsController < ApplicationController
    require 'net/imap'
    require 'mail'
    def index
        # imap
        imap_host = 'imap.gmail.com'
        imap_usessl = true
        imap_port = 993
        imap = Net::IMAP.new(imap_host, imap_port, imap_usessl)
        imap_user = ENV['ADDRESS']
        imap_passwd = ENV['PASSWD']
        imap.login(imap_user,imap_passwd)
        imap.select('INBOX')
        ids = imap.search(['ALL'])
        @mails = []
        imap.fetch(ids, "RFC822").each do |mail|
            m = Mail.new(mail.attr["RFC822"])
            if m.multipart?
                if m.html_part
                    @mails.push({ 
                        "date": m.date.to_s,
                        "subject": m.subject,
                        "body": m.html_part.decoded
                    })
                elsif m.text_part
                    @mails.push({
                        "date": m.date.to_s,
                        "subject": m.subject,
                        "body": m.text_part.decoded
                    })
                end
            else
                @mails.push({
                    "date": m.date.to_s,
                    "subject": m.subject,
                    "body": m.decoded
                })
            end
        end

        render json: { status: 'success', message: 'loaded latest 20 mails', data: @mails}
    end
end
