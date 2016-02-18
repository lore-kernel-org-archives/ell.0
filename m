Content-Type: multipart/mixed; boundary="===============4237036223357711140=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 01/10] dbus: Send InterfacesRemoved on object unregister
Date: Wed, 17 Feb 2016 21:50:38 -0600
Message-ID: <56C53F8E.4010307@gmail.com>
In-Reply-To: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4237036223357711140==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 02/15/2016 10:44 AM, Andrew Zaborowski wrote:
> Make sure we call _dbus_object_tree_remove_interface to do all the
> necessary steps of interface removal when an object from the tree
> together with its interfaces.
> ---
>   ell/dbus-service.c | 17 ++++++++++++++---
>   1 file changed, 14 insertions(+), 3 deletions(-)
>

All 10 patches applied, thanks.

Regards,
-Denis


--===============4237036223357711140==--

