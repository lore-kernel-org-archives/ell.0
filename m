Content-Type: multipart/mixed; boundary="===============7745888507093823490=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] util: Make l_container_of macro public
Date: Tue, 02 Apr 2019 12:02:23 -0500
Message-ID: <906a1dcf-01a5-5d4a-4c80-e032e1d22b4b@gmail.com>
In-Reply-To: <20190402163611.14690-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7745888507093823490==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

On 04/02/2019 11:36 AM, Micha=C5=82 Lowas-Rzechonek wrote:
> The macro is useful when e.g. scheduling timeouts, where l_timeout
> passed to l_timeout_notify_cb_t is a member of a larger object, and we
> would like to access this object while passing something else as
> user_data.
> ---
>   ell/dbus.c             | 8 ++++----
>   ell/dhcp-transport.c   | 6 +++---
>   ell/private.h          | 4 ----
>   ell/util.h             | 5 +++++
>   unit/test-dbus-watch.c | 4 ++--
>   5 files changed, 14 insertions(+), 13 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============7745888507093823490==--

