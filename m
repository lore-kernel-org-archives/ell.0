Content-Type: multipart/mixed; boundary="===============1920720419227502983=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: l_genl_family_new() successfully returns if generic netlink
 family doesn't exist.
Date: Thu, 16 Mar 2017 09:59:25 -0700
Message-ID: <CAPyD+=C+n-Rm7CPmqnpzj9+SCbsNZDJuQujif=-QLQdWDng+=Q@mail.gmail.com>
In-Reply-To: <326424ec-aa2e-299b-56b2-7cb86f5dc6e8@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1920720419227502983==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, Mar 15, 2017 at 8:08 PM, Denis Kenzior <denkenz@gmail.com> wrote:
>> A "vanished" watch never gets called since there is apparently no way
>> to set it beforehand.  Is that correct?
>
>
> You set it after-hand.  E.g.
> l_genl_family_new();
> l_genl_family_set_watches(family, family_appeared, family_vanished, ...);
>
> This works because the underlying CTRL_CMD_GETFAMILY is not actually sent
> over the socket until the next event loop iteration.

I figured I was missing something, and just confirmed that this works
as you described.

Thanks for your patience with my ELL newbie questions, Denis!  :)
-Ossama

--===============1920720419227502983==--

