Content-Type: multipart/mixed; boundary="===============7792105140526386612=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Tue, 02 Mar 2021 10:35:26 -0600
Message-ID: <7219a940-0eb2-11cc-3134-f6b8807c7d3c@gmail.com>
In-Reply-To: <CAOq732Ja+nFiHSSngd7B27Xt+7vx=CpS4fpMtUrsaaaX-brVEQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7792105140526386612==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> I do wonder why you'd cancel the command from the handler?
> =

> In the IWD AP case I want to cancel a dump command which I think is
> already handled correctly, but if the API can be made more robust then
> I think it's an improvement.  There can be complicated code paths
> where you destroy an object that owns the netlink command as a result
> of the command response.

Sure, I buy the more robust argument, though I still wonder how one would e=
ven =

get into such a state on purpose.  But the last sentence seems to be handwa=
ving? =

  So did you somehow trigger this condition or just fixing ghost bugs?

Regards,
-Denis
--===============7792105140526386612==--

