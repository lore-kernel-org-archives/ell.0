Content-Type: multipart/mixed; boundary="===============1616670023800983186=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Fix subpath comparisons in object tree walk
Date: Wed, 15 Aug 2018 11:55:57 -0500
Message-ID: <9c14ea71-94ed-70cc-3ff1-73c39bbec2de@gmail.com>
In-Reply-To: <20180815040245.22277-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1616670023800983186==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/14/2018 11:02 PM, Andrew Zaborowski wrote:
> By only using strncmp(child->subpath, path, len) we'd only check that
> child->subpath had path as its prefix in makepath_recurse.  As a
> result, if an object at /ab was added first and at /a second, the
> second object would not get a new node created and strangely none of
> our tests or users have caught this.

Funny.  How'd you catch this?

Also can we have a unit test please?

> ---
>   ell/dbus-service.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
> =

> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
> index 43c7a5c..cd9d402 100644
> --- a/ell/dbus-service.c
> +++ b/ell/dbus-service.c
> @@ -649,7 +649,8 @@ static struct object_node *makepath_recurse(struct ob=
ject_node *node,
>   	child =3D node->children;
>   =

>   	while (child) {
> -		if (!strncmp(child->subpath, path, end - path))
> +		if (!memcmp(child->subpath, path, end - path) &&
> +				child->subpath[end - path] =3D=3D '\0')

Hmm, is memcmp safe here?  What if child->subpath is smaller than end - =

path bytes?  Might be a good idea to make a unit test specifically for =

this and make sure ASAN/valgrind are happy.

>   			goto done;
>   =

>   		child =3D child->next;
> @@ -690,7 +691,8 @@ static struct object_node *lookup_recurse(struct obje=
ct_node *node,
>   	child =3D node->children;
>   =

>   	while (child) {
> -		if (!strncmp(child->subpath, path, end - path))
> +		if (!memcmp(child->subpath, path, end - path) &&
> +				child->subpath[end - path] =3D=3D '\0')
>   			return lookup_recurse(child->node, end);
>   =

>   		child =3D child->next;
> =


Regards,
-Denis

--===============1616670023800983186==--

