Content-Type: multipart/mixed; boundary="===============1025774423982343921=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Tue, 07 Jan 2020 17:37:37 +0000
Message-ID: <ac6ea44df69c53a6964aca5d7be03263c21bdfcd.camel@intel.com>
In-Reply-To: <0894e48d-212f-9d30-1526-a5da27eec5b0@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1025774423982343921==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis, Marcel, =


On Tue, 2020-01-07 at 09:51 -0600, Denis Kenzior wrote:
> Hi Brian,
> =

> > Any opinion on this change?  It is causing us build fails on some platf=
orms (including Raspberry PI 4).
> > =

> =

> I would think this is a compiler false positive.  If there was indeed an =

> issue, then just casting to void as an intermediate step just hides it =

> without fixing anything.

For what it is worth, the *usage* of l_container_of in all dbus.c instances=
 could be attacked from a different
direction...

In dbus.c, various functions are passed a (struct l_dbus *) argument, and f=
unction of l_container_of recovers
the pointer to a (struct l_dbus_classic *) member called "super".

And this is l_dbus_classic:

struct l_dbus_classic {
	struct l_dbus super;
	void *auth_command;
	enum auth_state auth_state;
	struct l_hashmap *match_strings;
	int *fd_buf;
	unsigned int num_fds;
};


So because super is the first member, the "recovered container pointer" sho=
uld *always* be equal to the
original pointer, and because the structure is *private to ell/dbus.c*, we =
can work around this warning by not
using l_container_of(), and instead simply casting the point directly in th=
e 4 places the macro is used. The
only time this would not work is if a compiler decides to re-arrange the me=
mbers of the container structure.

RFC patch:
diff --git a/ell/dbus.c b/ell/dbus.c
index 845ccb3..b4a1d42 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -102,7 +102,7 @@ struct l_dbus {
 };
 =

 struct l_dbus_classic {
-       struct l_dbus super;
+       struct l_dbus super; /* this member *must* be first */
        void *auth_command;
        enum auth_state auth_state;
        struct l_hashmap *match_strings;
@@ -578,8 +578,7 @@ static void dbus_init(struct l_dbus *dbus, int fd)
 =

 static void classic_free(struct l_dbus *dbus)
 {
-       struct l_dbus_classic *classic =3D
-               l_container_of(dbus, struct l_dbus_classic, super);
+       struct l_dbus_classic *classic =3D (struct l_dbus_classic *) dbus;
        unsigned int i;
 =

        for (i =3D 0; i < classic->num_fds; i++)
@@ -657,8 +656,7 @@ static bool classic_send_message(struct l_dbus *dbus,
 =

 static struct l_dbus_message *classic_recv_message(struct l_dbus *dbus)
 {
-       struct l_dbus_classic *classic =3D
-               l_container_of(dbus, struct l_dbus_classic, super);
+       struct l_dbus_classic *classic =3D (struct l_dbus_classic *) dbus;
        int fd =3D l_io_get_fd(dbus->io);
        struct dbus_header hdr;
        struct msghdr msg;
@@ -808,8 +806,7 @@ static bool classic_add_match(struct l_dbus *dbus, unsi=
gned int id,
                                const struct _dbus_filter_condition *rule,
                                int rule_len)
 {
-       struct l_dbus_classic *classic =3D
-               l_container_of(dbus, struct l_dbus_classic, super);
+       struct l_dbus_classic *classic =3D (struct l_dbus_classic *) dbus;
        char *match_str;
        struct l_dbus_message *message;
 =

@@ -832,8 +829,7 @@ static bool classic_add_match(struct l_dbus *dbus, unsi=
gned int id,
 =

 static bool classic_remove_match(struct l_dbus *dbus, unsigned int id)
 {
-       struct l_dbus_classic *classic =3D
-               l_container_of(dbus, struct l_dbus_classic, super);
+       struct l_dbus_classic *classic =3D (struct l_dbus_classic *) dbus;
        char *match_str =3D l_hashmap_remove(classic->match_strings,
                                                L_UINT_TO_PTR(id));
        struct l_dbus_message *message;

--===============1025774423982343921==--

