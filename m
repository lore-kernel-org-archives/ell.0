Content-Type: multipart/mixed; boundary="===============0556818117202973755=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: Re: [RFC] genl: Add a message builder API to help creating complex nl
 messages
Date: Wed, 25 Mar 2015 13:04:34 +0200
Message-ID: <55129642.9020105@linux.intel.com>
In-Reply-To: <55115AB9.9070603@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0556818117202973755==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

> I sent my own take on this.  I was playing around with it yesterday.

Which is the exact same thing as I first proposed in "[PATCH] genl: Add =

utility function no append nested attribute into a message"
plus the nested of nested stuff I added in the other one via the fixed =

table I advised also (on which I am still waiting feedback). That's fine.
But such API was requested to be moved into the "builder" type of thing =

like DBus does.

> The only thing I'm not sure about is whether the nested message length =

> is aligned or not.  Looking at libnl code it seems to be always =

> aligned, but if someone can whip up a quick unit test, that would be =

> really helpful. =


Seriously?


So guys what's the decision then: which API is the right one here?
Can we clear this up once and for all? There are dependent code that =

cannot proceed until this is over.
This is a show-stopper.

Tomasz

--===============0556818117202973755==--

