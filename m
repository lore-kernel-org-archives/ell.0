Content-Type: multipart/mixed; boundary="===============4537437472547113921=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: Is l_genl instance returned by l_genl_new() fully usable?
Date: Tue, 24 Oct 2017 15:13:46 -0500
Message-ID: <026bd2b3-8552-1548-a419-c52b962acdf9@gmail.com>
In-Reply-To: <CAPyD+=DrVWWynMDRohzcM91WFoTx5wqf3Q8MaTMBDhM+Fexm-g@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4537437472547113921==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 10/24/2017 02:55 PM, Othman, Ossama wrote:
> Hi Denis,
> =

> On Tue, Oct 24, 2017 at 10:44 AM, Denis Kenzior <denkenz@gmail.com =

> <mailto:denkenz@gmail.com>> wrote:
> =

>     On 10/24/2017 12:13 PM, Othman, Ossama wrote:
> =

>         While looking at ELL's generic netlink code, I noticed that
>         l_genl_new() is part of the public API but it's not clear if the
>         returned struct l_genl instance is fully usable since its pid
>         field isn't set as in l_genl_new_default(), and since there's is
>         no way to set it afterward.=C2=A0 This could result in the underl=
ying
>         sockaddr_nl nl_pid field being different from l_genl's pid field
>         (zero in this case).=C2=A0 Is that correct?
> =

> =

>     We don't actually use l_genl_new anywhere.=C2=A0 And it is not unit
>     tested. However, looking at man 7 netlink, it states that nl_pid
>     should be set to 0 whenever the destination is in the kernel (which
>     for us is always the case at the moment).=C2=A0 So I'm not sure that =
the
>     pid field is even needed?=C2=A0 At least setting nl_pid to 0 in
>     can_write_data doesn't seem to break anything.
> =

> =

> In l_genl_new_default(), the zero valued nl_pid field is set to a =

> non-zero value after the call to bind(), which is then assigned to =

> l_genl's pid field for later use in can_write_data().=C2=A0 I don't know =


Correct.  However note that we use the pid field to set the nlmsg_pid =

field.  Which the kernel never looks at as far as I can tell. =

Everything in the kernel uses the actual socket nl_pid, which makes =

sense anyway otherwise you could fake who you are.

> enough about the netlink implementation in the kernel to understand if =

> the nl_pid value assigned by the kernel during the call to bind() makes =

> a difference, but if it does wouldn't we need to keep the l_genl pid =

> field intact?
> =


In theory you are correct.  However it doesn't appear that nlmsg_pid =

field is ever looked at.  Hence my earlier question of whether this =

tracking code and the pid member value is even needed.

Regards,
-Denis

--===============4537437472547113921==--

