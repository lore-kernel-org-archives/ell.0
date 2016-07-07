Content-Type: multipart/mixed; boundary="===============9188659325788373584=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3] genl: Add unicast handler
Date: Thu, 07 Jul 2016 18:52:33 -0500
Message-ID: <577EEB41.1020307@gmail.com>
In-Reply-To: <0734F1C385189A4F8523BB7BB31464D74D379661@fmsmsx111.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9188659325788373584==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

 >>
>> So to me this pid argument seems unnecessary.  Also, this change is side-
>> effecting l_genl_new(int fd) method which you are removing.  While nobody
>> is using it at the moment, removing it in this fashion is poor style (si=
nce
>> l_genl_set_close_on_unref is mostly meant for this constructor)
>
> FYI: This was your suggestion to my original patch .

Was it?  Don't recall.  I was probably under the assumption that pid =

setting was required.  I do reserve the right to change my mind, =

especially when looking at things more closely ;)

I'm picking on the procedural aspect.  E.g. if we remove something, then =

we should make sure it is done thoroughly (maybe even in a separate =

commit) and hopefully mention it in the commit description.

Once you start using git blame and hunting for why a piece of code looks =

the way it looks, having nice git history becomes paramount.

>>>
>>> +bool l_genl_set_unicast_handler(struct l_genl *genl,
>>> +						l_genl_msg_func_t handler,
>>> +						void *user_data,
>>> +						l_genl_destroy_func_t
>> destroy);
>>> +
>>> +bool l_genl_unset_unicast_handler(struct l_genl *genl);
>>
>> I rather we simply use l_genl_set_unicast_handler with NULL handler
>> argument to accomplish this.
>
> I was thinking about it, but then the API does not look self-explanatory.
>

This is inconsistent with the rest of ell API though.  For example, see =

l_io_set_read_handler, l_io_set_write_handler, =

l_io_set_disconnect_handler, etc.  Any clarifying details can also be =

added to the docs.

Regards,
-Denis


--===============9188659325788373584==--

