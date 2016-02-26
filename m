Content-Type: multipart/mixed; boundary="===============2421282432724464400=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] dbus: Coalesce InterfacesAdded/Removed signals
Date: Fri, 26 Feb 2016 14:27:28 -0600
Message-ID: <56D0B530.1060306@gmail.com>
In-Reply-To: <1455765612-6577-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2421282432724464400==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 02/17/2016 09:20 PM, Andrew Zaborowski wrote:
> When multiple interfaces are added or removed during the same main loop
> cycle emit one signal per object with all the interfaces added or
> removed.  Move the signals to the idle callback.
> ---
>   ell/dbus-service.c | 337 ++++++++++++++++++++++++++++++++++++++++------=
-------
>   1 file changed, 257 insertions(+), 80 deletions(-)

I looked over these and was fine with them.  I went ahead and applied =

all five patches.  I did tweak some naming afterward to be more =

consistent.  Please eyeball that and let me know if you're okay with those.

One question I have is whether we could save a bit of space by =

coalescing the path and object pointers in the three record objects into =

a single structure.  E.g. go from

struct interface_add_record {
         char *path;
         struct object_node *object;
         struct l_queue *instances;
};

struct interface_remove_record {
         char *path;
         struct object_node *object;
         struct l_queue *interface_names;
};

struct property_change_record {
         char *path;
         struct object_node *object;
         struct interface_instance *instance;
         struct l_queue *properties;
};

to:

struct emit_signal_record {
	char *path;
	struct object_node *object;
	struct l_queue *removed_interface_names;
	struct l_queue *added_interface_instances;
	struct l_queue *changed_properties;
};

?

Regards,
-Denis

--===============2421282432724464400==--

