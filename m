Content-Type: multipart/mixed; boundary="===============6687881066760135476=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Mon, 27 Mar 2017 00:07:24 -0500
Message-ID: <7dd25efd-ecd2-84b2-60df-361350566983@gmail.com>
In-Reply-To: <20170323151235.11997-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6687881066760135476==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/23/2017 10:12 AM, Andrew Zaborowski wrote:
> Make sure the PropertiesChanged and InterfacesAdded/Removed signals
> related to one object path are sent to the dbus socket in the order
> that they are generated in.
> ---
>  ell/dbus-private.h |  2 ++
>  ell/dbus-service.c | 85 +++++++++++++++++++++++++++++++++++++++---------=
------
>  ell/dbus.c         |  5 ++++
>  3 files changed, 68 insertions(+), 24 deletions(-)
>

<snip>

>  	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
>  			entry =3D entry->next) {
>  		manager =3D entry->data;
>
> -		while ((interfaces_removed_rec =3D
> -				l_queue_pop_head(manager->announce_removed))) {
> +		while ((interfaces_removed_rec =3D l_queue_remove_if(
> +						manager->announce_removed,
> +						match_interfaces_removed_object,
> +						node))) {

So we're going from O(n) loop here to something like O(n^2) loop.  Can =

this be made a bit smarter?  Same goes for the other loop changes below. =

  Otherwise I'm fine with the general approach.

Regards,
-Denis

--===============6687881066760135476==--

