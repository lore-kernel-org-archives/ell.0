Content-Type: multipart/mixed; boundary="===============8039784163984339569=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RFC] genl: Add utility function no append nested attribute into
 a message
Date: Tue, 24 Feb 2015 09:14:55 -0800
Message-ID: <D401E2A3-76AF-4D6B-9D36-83D24F2CC6F8@holtmann.org>
In-Reply-To: <54EC40DE.5080006@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8039784163984339569==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

> I need your input on that one.
> I am not 100% sure it needs to align the message once we set the length
> of the nested arguments. Does it needs to set some padding then?

if it is the last one, then you might not need to. However if it is not the=
 last one, then you do need to align it.

Regards

Marcel


--===============8039784163984339569==--

