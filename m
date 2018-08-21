Content-Type: multipart/mixed; boundary="===============5204517635784813836=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Avoid memcmp for string comparison
Date: Tue, 21 Aug 2018 09:51:34 -0500
Message-ID: <616e8a28-9124-dffa-2dc2-9aa748781bc8@gmail.com>
In-Reply-To: <20180821031254.31527-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5204517635784813836==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/20/2018 10:12 PM, Andrew Zaborowski wrote:
> As discussed in
> https://lists.01.org/pipermail/ell/2018-August/001279.html gcc's Address
> Sanitizer may complain if we try using memcmp(A, B, len) to compare a
> null-terminated A shorter than len against a longer B so use strncmp
> instead.
> ---
>   ell/dbus-service.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis


--===============5204517635784813836==--

