Content-Type: multipart/mixed; boundary="===============8093086647871763501=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Fix disconnect watch with unique bus names
Date: Wed, 09 Nov 2016 14:14:25 -0600
Message-ID: <582383A1.5020103@gmail.com>
In-Reply-To: <1478659894-7142-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8093086647871763501==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/08/2016 08:51 PM, Andrew Zaborowski wrote:
> Make the dbus-name-cache, service watches and disconnect watches work
> with unique bus names.  Problem spotted by Daniel Wagner and culprit
> pointed out by Denis Kenzior.
> ---
>   ell/dbus-name-cache.c | 3 ---
>   1 file changed, 3 deletions(-)
>

Both applied, thanks.

Regards,
-Denis


--===============8093086647871763501==--

