Content-Type: multipart/mixed; boundary="===============4343480681792219649=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 14/20] dbus: Don't send replies to messages with no reply
 flag.
Date: Tue, 15 Mar 2016 11:35:43 -0500
Message-ID: <56E839DF.6020305@gmail.com>
In-Reply-To: <CAOq732K+mgFFkQQM_nwseppm8z45zC9g16RaUyD_iquXVtv8XA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4343480681792219649==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/14/2016 05:15 PM, Andrzej Zaborowski wrote:
> Hi Denis,
>
> On 14 March 2016 at 18:11, Denis Kenzior <denkenz@gmail.com> wrote:
>> Hi Andrew,
>>
>> On 03/13/2016 10:41 PM, Andrew Zaborowski wrote:
>>>
>>> Kdbus doesn't store the cookies for messages that have the no reply flag
>>> and throws error when a reply is sent with reply_cookie that it doesn't
>>> know.  It's not fatal, but we also save some cycles by not sending the
>>> message.  A further change could be made to not even let users create a
>>> message as a return from a method call but that may be confusing.
>>> ---
>>>    ell/dbus-service.c | 8 ++++++--
>>>    1 file changed, 6 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
>>> index b4e0b60..c1ed9ec 100644
>>> --- a/ell/dbus-service.c
>>> +++ b/ell/dbus-service.c
>>> @@ -1624,8 +1624,12 @@ bool _dbus_object_tree_dispatch(struct
>>> _dbus_object_tree *tree,
>>>                  return false;
>>>
>>>          reply =3D method->cb(dbus, message, instance->user_data);
>>> -       if (reply)
>>> -               l_dbus_send(dbus, reply);
>>> +       if (reply) {
>>> +               if (l_dbus_message_get_no_reply(message))
>>> +                       l_dbus_message_unref(reply);
>>> +               else
>>> +                       l_dbus_send(dbus, reply);
>>> +       }
>>
>>
>> Okay, but this doesn't solve the issue for async method returns.
>>
>
> True, I forgot about that.
>
>> Should we
>> save the no_reply flag inside l_dbus_message_new_method_return &
>> l_dbus_message_new_error and then take care of this inside l_dbus_send?
>
> I was thinking of modifying l_dbus_message_new_method_return to set
> message->destination to NULL or returning an error.
>

Returning an error is bad, since the code might not be setup to handle =

noreply messages.  Any client can call any method call on the service =

and just randomly set the noreply flag.  If we return an error, then =

half our method handlers might crash.  And I don't necessarily want to =

check for the noreply flag in every method handler.

I think the easiest way would be to just add a noreply flag inside =

l_dbus_message (similar to bool sealed) and just not put the message on =

the wire if that flag is set.

Regards,
-Denis

--===============4343480681792219649==--

