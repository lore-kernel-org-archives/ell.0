Content-Type: multipart/mixed; boundary="===============6422637407763340223=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/2] Improve genl with a message builder 
Date: Wed, 04 Mar 2015 06:17:10 -0800
Message-ID: <6DDA26A3-DC7B-406C-9881-BBB8CCCAD1C9@holtmann.org>
In-Reply-To: <1425474355-30536-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6422637407763340223==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

> I could not test yet the whole patch set so it's sent here for a quick re=
view.
> =

> First patch is there since I realized genl lacked of those LIB_EXPORT and=
 unlikely().
> Minor stuff so.
> =

> Second patch is the interesting one.
> =

> I am currently building a unit test for it. Getting some reliable nested =
based messages
> to compare with is the annoyingly time consuming part here.

I do not know what will be so "annoyingly time consuming" in getting nested=
 generic netlink messages for your unit tests. We have iwmon and it can cre=
ate PCAP files. So start iwmon -w <file> and run wpa_supplicant to connect =
to your access point. Open Wireshark and you have your raw data that you ca=
n copy and put into a unit test. It is really as simple as that.

Unit tests for low level protocols are essential. The more the better. I wo=
uld not accept patches that do not have unit tests attached with it. Spendi=
ng extra time on unit tests is time well spent. It will save you a lot head=
aches later on.

Regards

Marcel


--===============6422637407763340223==--

