Content-Type: multipart/mixed; boundary="===============3122809371056574401=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH] genl: Fix casting error
Date: Fri, 14 Jul 2017 10:26:41 -0700
Message-ID: <CAPyD+=CC-2OHWNce2rsftcoeziOD3=Y6Vdq9TUJ8+RkCab7fbg@mail.gmail.com>
In-Reply-To: <20170714171428.1714-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3122809371056574401==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On Fri, Jul 14, 2017 at 10:14 AM, Tim Kourt <tim.a.kourt@linux.intel.com>
wrote:
>
> -       for (nlmsg =3D iov.iov_base; NLMSG_OK(nlmsg, bytes_read);
> +       for (nlmsg =3D iov.iov_base; NLMSG_OK(nlmsg, (uint32_t) bytes_rea=
d);


NLMSG_OK() expects an int for the second argument.  Assuming truncation
isn't an issue here, wouldn't it be better to cast to an int instead?

-Ossama

--===============3122809371056574401==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGkgVGltLDxkaXYgY2xhc3M9ImdtYWlsX2V4dHJhIj48YnI+PGRpdiBj
bGFzcz0iZ21haWxfcXVvdGUiPk9uIEZyaSwgSnVsIDE0LCAyMDE3IGF0IDEwOjE0IEFNLCBUaW0g
S291cnQgPHNwYW4gZGlyPSJsdHIiPiZsdDs8YSBocmVmPSJtYWlsdG86dGltLmEua291cnRAbGlu
dXguaW50ZWwuY29tIiB0YXJnZXQ9Il9ibGFuayI+dGltLmEua291cnRAbGludXguaW50ZWwuY29t
PC9hPiZndDs8L3NwYW4+IHdyb3RlOjxibG9ja3F1b3RlIGNsYXNzPSJnbWFpbF9xdW90ZSIgc3R5
bGU9Im1hcmdpbjowcHggMHB4IDBweCAwLjhleDtib3JkZXItbGVmdDoxcHggc29saWQgcmdiKDIw
NCwyMDQsMjA0KTtwYWRkaW5nLWxlZnQ6MWV4Ij4KLcKgIMKgIMKgIMKgZm9yIChubG1zZyA9IGlv
di5pb3ZfYmFzZTsgTkxNU0dfT0sobmxtc2csIGJ5dGVzX3JlYWQpOzxicj4KK8KgIMKgIMKgIMKg
Zm9yIChubG1zZyA9IGlvdi5pb3ZfYmFzZTsgTkxNU0dfT0sobmxtc2csICh1aW50MzJfdCkgYnl0
ZXNfcmVhZCk7PC9ibG9ja3F1b3RlPjxkaXY+PGJyPjwvZGl2PjxkaXY+TkxNU0dfT0soKSBleHBl
Y3RzIGFuIGludCBmb3IgdGhlIHNlY29uZCBhcmd1bWVudC7CoCBBc3N1bWluZyB0cnVuY2F0aW9u
IGlzbiYjMzk7dCBhbiBpc3N1ZSBoZXJlLCB3b3VsZG4mIzM5O3QgaXQgYmUgYmV0dGVyIHRvIGNh
c3QgdG8gYW4gaW50IGluc3RlYWQ/PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj4tT3NzYW1hPC9k
aXY+PGRpdj48YnI+PC9kaXY+PC9kaXY+PC9kaXY+PC9kaXY+Cg==

--===============3122809371056574401==--

