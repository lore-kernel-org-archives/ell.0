Content-Type: multipart/mixed; boundary="===============2791808502887323610=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Free instance only after all references removed
Date: Wed, 27 Sep 2017 09:53:04 -0500
Message-ID: <1a291c6c-e6d9-1055-d1f9-91eaa29c4242@gmail.com>
In-Reply-To: <20170927125845.20880-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2791808502887323610==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 09/27/2017 07:58 AM, Andrew Zaborowski wrote:
> In _dbus_object_tree_remove_interface move the freeing of the instance
> object to after we've dropped any queued Property Change and Interface
> Added/Removed records referring to that instance.  We didn't really need
> the object around for that (only the pointer) but we want to be extra
> careful.
> ---
>   ell/dbus-service.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============2791808502887323610==--

