Content-Type: multipart/mixed; boundary="===============5562643279035523908=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: Re: [RFC] genl: Add utility function no append nested attribute into
 a message
Date: Wed, 25 Feb 2015 13:25:29 +0200
Message-ID: <54EDB129.80306@linux.intel.com>
In-Reply-To: <D401E2A3-76AF-4D6B-9D36-83D24F2CC6F8@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5562643279035523908==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

>> I need your input on that one.
>> I am not 100% sure it needs to align the message once we set the length
>> of the nested arguments. Does it needs to set some padding then?
> if it is the last one, then you might not need to. However if it is not t=
he last one, then you do need to align it.

Let's always align then.

Tomasz

--===============5562643279035523908==--

