Content-Type: multipart/mixed; boundary="===============4114036644390898230=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/9] dbus: Separate interface registration from
 instantiation
Date: Thu, 11 Feb 2016 13:52:29 -0600
Message-ID: <56BCE67D.8000803@gmail.com>
In-Reply-To: <1455101156-3587-5-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4114036644390898230==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 02/10/2016 04:45 AM, Andrew Zaborowski wrote:
> Currently l_dbus_register_interface performs three related actions:
>   * if needed, creates a new object node in the dbus object tree
>   * if needed, sets up internal structs for the new interface
>   * adds the interface to the object
>
> With this patch these are three spearate calls, although the first
> is still performed automatically by l_dbus_add_interface if
> l_dbus_register_object wasn't called first.  This is in preparation for
> ObjectManager support.  With this the setup_func parameter and new
> interface parameters don't need to be passed every time an interface is
> instiated, only when it's being registered/created.
>
> Note that while the client doesn't need to call l_dbus_register_object,
> they still need to call l_dbus_unregister_object to free the object
> because it's not freed automatically when the last interface gets
> removed.  But they can skip the l_dbus_remove_interface calls
> because the interfaces will be removed either way.
> ---
>   ell/dbus-private.h |  22 ++++--
>   ell/dbus-service.c | 192 ++++++++++++++++++++++++++++++++++++++++------=
-------
>   ell/dbus.c         | 147 ++++++++++++++++++++++++++++++++++++++--
>   ell/dbus.h         |  19 ++++--
>   4 files changed, 318 insertions(+), 62 deletions(-)
>

<snip>

> diff --git a/ell/dbus.c b/ell/dbus.c
> index 14849e8..796240f 100644
> --- a/ell/dbus.c
> +++ b/ell/dbus.c

<snip>

> +
> +LIB_EXPORT bool l_dbus_object_remove_interface(struct l_dbus *dbus,
> +						const char *object,
> +						const char *interface)

You forgot to add documentation for this one :)

> +{
> +	if (unlikely(!dbus))
> +		return false;
> +
> +	if (unlikely(!dbus->tree))
> +		return false;
> +
> +	return _dbus_object_tree_remove_interface(dbus->tree, object,
> +							interface);
>   }
>

Regards,
-Denis


--===============4114036644390898230==--

