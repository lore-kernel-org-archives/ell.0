Content-Type: multipart/mixed; boundary="===============8753080280004023468=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/9] tls: Pass the verified peer identity to "ready"
 callback
Date: Tue, 27 Nov 2018 22:16:38 -0600
Message-ID: <7d1d5073-c998-371c-da4c-c1e9c83b7c38@gmail.com>
In-Reply-To: <20181128023835.2081-4-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8753080280004023468==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/27/2018 08:38 PM, Andrew Zaborowski wrote:
> Extract a human-readable peer identity string from the supplied
> certificate and pass it to the ready callback provided by API user to
> indicate that the peer has actually been authenticated.  For some users
> it will only really matter whether the value is non-NULL meaning that
> the peer is trusted by the locally configured CA, while for others,
> such as web browsers it's useful to display a human-readable peer
> identity to the user so they can see if a website is served by who they
> think it belongs to.  If we got a peer certificate but user supplied no
> CAs or peer couldn't be authenticated, don't bother to extract the
> identity string and pass NULL.
> =

> Until now we'd always pass NULL (there was a TODO comment) because
> we'd hoped we could at some point leverage the kernel's certificate
> parser to extract the subject name.  The newly added
> tls_get_peer_identity_str might also fit in cert.c instead of tls.c.
> ---
>   ell/tls.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
>   1 file changed, 67 insertions(+), 3 deletions(-)
> =


I went ahead and applied this and patch 5.  But really the more =

interesting feature for us would be the certificate element name =

matching described in the appropriate iwd.git/TODO task.  But that one =

is a whole other story...

Regards,
-Denis

--===============8753080280004023468==--

