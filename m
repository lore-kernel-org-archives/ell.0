Content-Type: multipart/mixed; boundary="===============8033644297115125367=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Fix array handling in
 l_dbus_message_builder_append_from_iter
Date: Tue, 28 Nov 2017 09:48:48 -0600
Message-ID: <c25a00d3-de87-9058-b74b-b1ed41a67678@gmail.com>
In-Reply-To: <20171128150642.28634-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8033644297115125367==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Szymon,

On 11/28/2017 09:06 AM, Szymon Janc wrote:
> For array it is needed to iterate over its elements rather than
> signature.
> ---
>   ell/dbus-message.c | 10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============8033644297115125367==--

