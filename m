Content-Type: multipart/mixed; boundary="===============5159938661397489085=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC] genl: Add a message builder API to help creating complex nl
 messages
Date: Tue, 24 Mar 2015 07:38:17 -0500
Message-ID: <55115AB9.9070603@gmail.com>
In-Reply-To: <1427196109-21373-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5159938661397489085==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

On 03/24/2015 06:21 AM, Tomasz Bursztyka wrote:
> ---
>
> Hi Marcel,
>
> Quickly, as an RFC, does this look better?
> For building message I think either one uses l_genl_msg or l_genl_msg_bui=
lder.
> Thus I changed l_genl_msg_builder_new(): it creates the l_genl_msg by its=
elf.
>
> Only when one calls l_genl_msg_builder_finalize(), he will get a referenc=
e on
> the message. Such reference l_genl_family_send() will unref, or that he w=
ill
> in case of error.
>
> Does that look saner? At least it avoids the user to call l_genl_msg_new()
> and again l_genl_msg_builder() afterwards. I think it's better to separate
> properly both.
>
> I kept the queue for the nested of nested etc... I still want your opinio=
n:
> either a queue or a fixed depth of nested of nested ? or we don't care?
> (I think we do care).
>

I sent my own take on this.  I was playing around with it yesterday. =

The only thing I'm not sure about is whether the nested message length =

is aligned or not.  Looking at libnl code it seems to be always aligned, =

but if someone can whip up a quick unit test, that would be really helpful.

Regards,
-Denis


--===============5159938661397489085==--

