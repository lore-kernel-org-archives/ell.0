Content-Type: multipart/mixed; boundary="===============7675842050841192034=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Mon, 27 Mar 2017 23:34:20 +0200
Message-ID: <CAOq732Ka0xVs-MArKRFEL9jb8PU7Z=ZG-LNbjqJFsVhc7-xreA@mail.gmail.com>
In-Reply-To: <7dd25efd-ecd2-84b2-60df-361350566983@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7675842050841192034==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

 Hi Denis,

On 27 March 2017 at 07:07, Denis Kenzior <denkenz@gmail.com> wrote:
> On 03/23/2017 10:12 AM, Andrew Zaborowski wrote:
>>         for (entry =3D l_queue_get_entries(tree->object_managers); entry;
>>                         entry =3D entry->next) {
>>                 manager =3D entry->data;
>>
>> -               while ((interfaces_removed_rec =3D
>> -
>> l_queue_pop_head(manager->announce_removed))) {
>> +               while ((interfaces_removed_rec =3D l_queue_remove_if(
>> +                                               manager->announce_remove=
d,
>> +
>> match_interfaces_removed_object,
>> +                                               node))) {
>
>
> So we're going from O(n) loop here to something like O(n^2) loop.  Can th=
is
> be made a bit smarter?  Same goes for the other loop changes below.
> Otherwise I'm fine with the general approach.

Ok, I pondered using l_queue_foreach_remove but had opted for a smaller pat=
ch.

Best regards

--===============7675842050841192034==--

