#!/bin/bash
# author : ch1ngiz

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'

usage(){
echo -e ""
echo -e "${RED}Usage: ./portDetector <IP-LIST> <SENDER-EMAIL> <RECEIVER-EMAIL> <SENDER-EMAIL-PASSWORD> <MAIL-SERVER>"
echo -e ""
exit 1
}

initialScan(){

for ip in $(cat $ip_addresses)

do
        mkdir $ip > /dev/null 2>&1
        echo -e "${GREEN}[+] Initial Scaning on $ip [+]"
        nmap -p 1-65535 $ip --min-parallelism 100 -sS -sU -T4 -n --open -oN $ip/$ip.Full.txt > /dev/null
done

}

postScan(){

for ip in $(cat $ip_addresses)
do
        declare hash1=$(cat $ip/$ip.Full.txt | grep -E '/tcp|/udp' | md5sum | cut -d " " -f1)
        echo -e "${GREEN}[+] Secondary Scanning on $ip... [+]"
        initialPorts=$(cat $ip/$ip.Full.txt | grep -E '/tcp|/udp' | cut -d "/" -f1 | tr '\n' ',' | sed 's/.$//')
        nmap -p 1-65535 $ip --min-parallelism 100 -sS -sU -T4 -n --open -oN $ip/$ip.Full.txt > /dev/null
        declare hash2=$(cat $ip/$ip.Full.txt | grep -E '/tcp|/udp' | md5sum | cut -d " " -f1)
        postPorts=$(cat $ip/$ip.Full.txt | grep -E '/tcp|/udp' | cut -d "/" -f1 | tr '\n' ',' | sed 's/.$//')
        if [ $hash1 != $hash2 ]
        then
                echo -e "${GREEN}[+] Changes detected on this ip: $ip [+]"
                echo -e "${YELLOW}[+] Previuos port(s): $initialPorts [+]"
                echo -e "${YELLOW}[+] Current port(s): $postPorts [+]"
                message="Change(s) detected on this ip: $ip, Previous port(s): $initialPorts, Current port(s): $postPorts"
                subject="Change(s) Detected on $ip!"
                sendMail
        fi
done
}

sendMail(){

message=$message
subject=$subject

output=`python <<END

import smtplib

def main():

        sender = "$sender"
        receiver = "$receiver"
        message = "$message"
        subject = "$subject"
        password = "$password"
        mailserver = "$mailserver"

        from email.mime.multipart import MIMEMultipart
        from email.mime.text import MIMEText

        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = sender
        msg['To'] = receiver


        html = ""
        html += '<html>\n'
        html += '<head>\n'
        html += '<style\n>'
        html += 'p {\n'
        html += 'font-family: "Courier New", Courier, monospace;\n'
        html += '}\n'
        html += '</style>\n'
        html += '</head>\n'
        html += '<body>\n'
        html += '<font color="red"><p>' + str(message) + '</p></font>\n'
        html += '<p>Kind Regards,</p>\n'
        html += "<p>Mr.Port Detector</p>"
        html += '</body>'
        html +='</html>'

        part2 = MIMEText(html, 'html')

        msg.attach(part2)

        try:
                s = smtplib.SMTP(mailserver,587)

        except Exception as e:
                print (e)
                mtplib.SMTP_SSL(mailserver, 465)
        s.ehlo()
        s.starttls()
        s.login(sender, password)
        s.sendmail(sender, receiver, msg.as_string())
        s.quit()
        pass

if __name__ == "__main__": main()
END`

echo $output
}

ip_addresses="$1"
sender="$2"
receiver="$3"
password="$4"
mailserver="$5"

if [[ -z $1 || -z $2 || -z $3 || -z $4 || -z $5 ]]
then
        usage
else
        while true
        do
                initialScan
                sleep 7200
                postScan
        done
fi

