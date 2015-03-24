Content-Type: multipart/mixed; boundary="===============5994677022064887185=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: Re: [PATCH 2/4] genl: Add a message builder API to help creating
 complex nl messages
Date: Tue, 24 Mar 2015 10:12:28 +0200
Message-ID: <55111C6C.8080203@linux.intel.com>
In-Reply-To: <550BDF83.3070303@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5994677022064887185==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

>> do we really need a queue here? Can we not just store the latest =

>> offset. Also how do you do nested of nested attributes?
>
> Nested of nested exists, in nftables for instance.
> Unless we prefer to have a fixed depth of nested of nested (like 3, =

> 4...?),
> we need such dynamically allocated list.
>
> I haven't tested this case, but we have to handle it.
> Unless we plan to use that code for nl80211 only.
>
>>> +    }
>>> +
>>> +    // In case nothing has been appended into the nested attribute
>>> +    // it could try to be smart and revert the message back and =

>>> return true
>> this is not our comment style. Please respect the coding style.
>
> Actually, it's more like a question that needs an answer. I don't want =

> this comment to go in anyway.
> Or let's just forget entirely about this.
>
>>> +struct l_genl_msg *l_genl_msg_builder_finalize(
>>> +                    struct l_genl_msg_builder *builder);
>> So I saw that l_dbus_message_builder does a similar thing. We give in =

>> a message to start from and then we get that message back out when =

>> finalizing it. Has anything changed in between or why are we doing this?
>
> The rule was to follow what DBus API does. But I think it's useless:
> - l_genl_msg_builder_new()  it could take a size, and create the msg =

> internally. (or have a fixed size of 512bytes, and if really needed =

> would realloc relevantly?)
> - then if everything went well: l_genl_msg_builder_finalize() would =

> return a msg pointer (a reference of it actually), which one we could =

> use to send  (and send unref the msg).
>
> Less function to call from client code.
> It's actually awkward that you have to create the msg yourself, then =

> also a builder with it etc...
> when you have also other functions to append attributes directly in =

> the msg.
> At least in dbus api you can't append anything BUT through a builder.
> (So yes I don't want to follow the DBus Api but finally a bit anyway...)
>
> The naming is too long as well, l_genl_msg_builder_append_attribute() =

> mostly.
> Suggestions would be welcome. I can strip the "ibute" at the end at =

> least.
> And also msg_builder into _msgbld_ or does the lack of vowels makes it =

> even crappier?


Any comment on this?
Would be nice if I can solve all that, api and unit test, at once.

Tomasz

--===============5994677022064887185==--

