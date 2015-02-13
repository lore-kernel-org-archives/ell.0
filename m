Content-Type: multipart/mixed; boundary="===============4390175726856672573=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Fri, 13 Feb 2015 11:04:45 -0600
Message-ID: <54DE2EAD.4090301@gmail.com>
In-Reply-To: <CABBYNZ+TsZYKNE54-BT7UKDAcwwcZUyoSpHfmuZyeDs3VAGoTw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4390175726856672573==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Luiz,

 >> So you need to find an alternate approach.  Think through your data
>> structures carefully.
>
> Ive solved a similar problem with queues in BlueZ, it is very similar
> to ell queues, the code looks like this now:
>
> http://fpaste.org/185237/14238402/

We're not going to increase memory consumption by 25% just to support a =

few corner cases involving re-entrancy.  Even STL containers don't =

support the usage models you guys want to support.

So I repeat this again, leave queues and hashmaps alone.  Handle =

re-entrancy separately.

Lets move on please ;)

Regards,
-Denis

--===============4390175726856672573==--

