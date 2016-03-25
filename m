Content-Type: multipart/mixed; boundary="===============8867430163219247879=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 09/15] dbus: Classic dbus filter_ops implementation.
Date: Sat, 26 Mar 2016 00:30:12 +0100
Message-ID: <CAOq732LA00ZUQ=2rc0LDSgmLMJKOh7ivQkdFuBg7Cm=B_N26nw@mail.gmail.com>
In-Reply-To: <56F426BB.4020105@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8867430163219247879==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 24 March 2016 at 18:41, Denis Kenzior <denkenz@gmail.com> wrote:
> On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
>>
>> For the name owner tracking I decided to subscribe to all name
>> owner changes instead of adding separate rules for every name because
>> in some scenarios that saves us cycles/memory and we don't have
>> to hold a list of IDs of every such rule so that we could remove them
>> when no longer needed.
>> ---
>>   ell/dbus.c | 135
>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 135 insertions(+)
>>
>
> I went ahead and applied this one.
>
> One thought / suggestion below:
>
>> +static bool classic_remove_match(struct l_dbus *dbus, unsigned int id)
>> +{
>> +       struct l_dbus_classic *classic =3D
>> +               container_of(dbus, struct l_dbus_classic, super);
>> +       char *match_str =3D l_hashmap_remove(classic->match_strings,
>> +                                               L_UINT_TO_PTR(id));
>
>
> DBus-1 doesn't reference the AddMatch/RemoveMatch stuff by id, so we store
> the match strings here for future lookup.
>
> In theory, we could get rid of this hashmap by sending in the full rule s=
et
> into the remove_match method as well.  If I grok things correctly, the
> information is present in the filter_node structures, we'd just need to
> build the rule set during remove_recurse, which can be done with a simple
> stack structure.
>
> This should save us some run-time memory at the expense of a bit more
> processing.

Yes, this would be possible.  This is similar to how the object tree
in dbus-service.c could rebuild the paths from node pointers but
instead some functions receive the path string and the node pointer to
avoid this.  Let's keep thinking if we want to do that, but the IDs
work well for kdbus.  If we change this, kdbus could pass a hash of
the rule string as the cookie.

Best regards

--===============8867430163219247879==--

