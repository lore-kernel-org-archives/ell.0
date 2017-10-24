Content-Type: multipart/mixed; boundary="===============5339314444927824744=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: Is l_genl instance returned by l_genl_new() fully usable?
Date: Tue, 24 Oct 2017 12:44:38 -0500
Message-ID: <5b2cacb2-4932-5d93-6345-96d22cc788e4@gmail.com>
In-Reply-To: <CAPyD+=CEfbATFiVO426Xs6ZvhfxQvOQCO3Hp2+d-8D0DMpKCzg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5339314444927824744==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 10/24/2017 12:13 PM, Othman, Ossama wrote:
> Hi,
> =

> While looking at ELL's generic netlink code, I noticed that l_genl_new() =

> is part of the public API but it's not clear if the returned struct =

> l_genl instance is fully usable since its pid field isn't set as in =

> l_genl_new_default(), and since there's is no way to set it afterward.  =

> This could result in the underlying sockaddr_nl nl_pid field being =

> different from l_genl's pid field (zero in this case).=C2=A0 Is that corr=
ect?
> =


We don't actually use l_genl_new anywhere.  And it is not unit tested. =

However, looking at man 7 netlink, it states that nl_pid should be set =

to 0 whenever the destination is in the kernel (which for us is always =

the case at the moment).  So I'm not sure that the pid field is even =

needed?  At least setting nl_pid to 0 in can_write_data doesn't seem to =

break anything.

Regards,
-Denis

--===============5339314444927824744==--

