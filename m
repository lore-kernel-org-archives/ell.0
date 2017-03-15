Content-Type: multipart/mixed; boundary="===============7484975173236907193=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: l_genl_family_new() successfully returns if generic netlink family
 doesn't exist.
Date: Wed, 15 Mar 2017 13:38:38 -0700
Message-ID: <CAPyD+=C_JaXz9TWBv6+kCGVCa3ZZeF6yQbq3x67VXrx+pwacZw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7484975173236907193==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

The function l_genl_family_new() successfully returns if the desired
generic netlink family isn't available in the kernel.  For example,
suppose one does the following:

    struct l_genl_family * family =3D l_genl_family_new(genl, "foo");

If the "foo" generic netlink family doesn't exist in the kernel, for
whatever reason, l_genl_family_new() will still return a valid
pointer.  Is this the expected behavior?

It looks like some code exists in the implementation that would have
allowed one to be notified of such a problem by calling a
user-specified "vanished" watch callback.  Specifically,
l_genl_family_new() constructs a CTRL_ATTR_FAMILY_NAME generic netlink
message with a callback function get_family_callback().  The latter
detects and handles an error like so:

    error =3D l_genl_msg_get_error(msg);
        if (error < 0) {
            if (family->watch_vanished)
                family->watch_vanished(family->watch_data);
               return;
    }

A "vanished" watch never gets called since there is apparently no way
to set it beforehand.  Is that correct?

Thanks!
-Ossama

--===============7484975173236907193==--

