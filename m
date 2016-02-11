Content-Type: multipart/mixed; boundary="===============3136120905108099945=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Fix read after free during cleanup
Date: Thu, 11 Feb 2016 13:50:25 -0600
Message-ID: <56BCE601.9050308@gmail.com>
In-Reply-To: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3136120905108099945==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 02/10/2016 04:45 AM, Andrew Zaborowski wrote:
> subtree_free will be checking if interfaces of objects being freed have
> a destroy callback so the interfaces should not be freed before that.
> ---
>   ell/dbus-service.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============3136120905108099945==--

