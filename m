Content-Type: multipart/mixed; boundary="===============7587829800987513781=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Add l_dbus_object_get_data
Date: Fri, 23 Aug 2019 18:46:24 -0500
Message-ID: <0f6125fa-c418-fe14-ae12-5f81eb1da5ab@gmail.com>
In-Reply-To: <20190824005337.24469-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7587829800987513781==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/23/19 7:53 PM, Andrew Zaborowski wrote:
> This function can be used by DBus method implementations that receive
> an object path as a parameter to directly look up the user_data by the
> path and interface name.
> ---
>   ell/dbus-private.h |  3 +++
>   ell/dbus-service.c | 19 +++++++++++++++++++
>   ell/dbus.c         | 13 +++++++++++++
>   ell/dbus.h         |  2 ++
>   ell/ell.sym        |  1 +
>   5 files changed, 38 insertions(+)
> =


Both applied, thanks.

Regards,
-Denis


--===============7587829800987513781==--

