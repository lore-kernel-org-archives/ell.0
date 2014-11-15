Content-Type: multipart/mixed; boundary="===============0216937516808007391=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] genl: Call vanished function on error when fetching
 netlink family info
Date: Fri, 14 Nov 2014 21:51:41 -0600
Message-ID: <5466CDCD.8070303@gmail.com>
In-Reply-To: <1414414084-11849-1-git-send-email-patrik.flykt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0216937516808007391==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 10/27/2014 07:48 AM, Patrik Flykt wrote:
> If initial information of the netlink family could not be received, call
> the registered generic netlink vanished function immediately. The reason
> for the error can for example be that the proper kernel module has not
> been loaded or the proper functionality has not been compiled in.
> ---
>
> There does not seem to be any way of communicating an error to the caller,
> which now will hang indefinitely waiting for an answer that is not coming.
> Thus improvising a bit with the currently unused 'vanished' callback.
> Another option is to always require a timer in the calling application.
>
> Cheers,
>
> 	Patrik
>
>
>   ell/genl.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>

Patch has been applied thanks.  I shortened the commit header since that =

should ideally be under 50 characters.

Regards,
-Denis


--===============0216937516808007391==--

