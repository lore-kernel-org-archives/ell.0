Content-Type: multipart/mixed; boundary="===============3894410106963394591=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] genl: Add l_genl_msg_attr_append_data
Date: Thu, 06 Oct 2016 02:31:50 +0200
Message-ID: <CAOq732KKY+GsV3Pgq2b9FHEAv-C8YVuZn1ehEGkUM6=BQXAuPw@mail.gmail.com>
In-Reply-To: <57F590DD.4050102@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3894410106963394591==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 6 October 2016 at 01:46, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
> On 10/05/2016 05:45 PM, Andrew Zaborowski wrote:
>>
>> Try to minimise the amount of buffers allocated and copied by clients
>> when building a message attribute that is a concatenation of other
>> buffers, such as an IE sequence.  The client would the following three
>> calls:
>>
>> l_genl_msg_enter_nested
>> l_genl_msg_attr_append_data
>> l_genl_msg_leave_nested
>
>
> So the intent here is that instead of:
> msg =3D l_genl_msg_new_sized(...);
> buf =3D alloca();
> // memcpy / scribble in buffer
> l_genl_msg_append_attr(msg, NL80211_ATTR_IE, buf_len, buf);
>
> we do something like:
> msg =3D l_genl_msg_new_sized(...);
> l_genl_msg_enter_nested(msg, NL80211_ATTR_IE);
> buf =3D l_genl_msg_attr_append_data(msg, len);
> // scribble in buf
> buf =3D l_genl_msg_attr_append_data(msg, len);
> // scribble in buf
> l_genl_msg_leave_nested(msg);
>
> ?
>
> If so, you're (very creatively) really abusing the intent of enter_nested
> which is used for true nested attributes.  Don't think I really like that=
...

Yes, I sent this more as an RFC with the intent to provide a better
named function instread of l_genl_msg_enter_nested but thought that
was a detail.

>
> Is l_genl_msg_append_attrv(msg, iov, iov_len) not sufficient?

Ok, let's do that instead.  I thought there could be additional
chances to avoid memcpys if we return a pointer to write to.

>
> Alternatively, we should do something like:
>
> l_genl_msg_attr_open(msg, NL80211_ATTR_IE);
> l_genl_msg_attr_reserve(msg, len);
> l_genl_msg_attr_append(msg, len, data);
> l_genl_msg_attr_reserve(msg, len);
> l_genl_msg_attr_close(msg);
>
> Regards,
> -Denis
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell

Best regards

--===============3894410106963394591==--

