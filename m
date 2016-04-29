Content-Type: multipart/mixed; boundary="===============7781343029937363570=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 5/5] unit: End to end FD passing test
Date: Fri, 29 Apr 2016 18:21:57 -0500
Message-ID: <5723EC95.3030606@gmail.com>
In-Reply-To: <1461969842-11704-5-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7781343029937363570==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 04/29/2016 05:44 PM, Andrew Zaborowski wrote:
> Doesn't really belong in test-dbus-properties.c...

This doesn't sound good ;)

> ---
>   unit/test-dbus-properties.c | 93 ++++++++++++++++++++++++++++++++++++++=
+++++++
>   1 file changed, 93 insertions(+)
>

Can we make a dedicated .c test file for this, and test both =

dbus-classic and kdbus transports there?

Regards,
-Denis

--===============7781343029937363570==--

