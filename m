Received: from mail-oa1-f53.google.com (mail-oa1-f53.google.com [209.85.160.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6DA597A
	for <ell@lists.linux.dev>; Tue, 14 Jun 2022 15:00:04 +0000 (UTC)
Received: by mail-oa1-f53.google.com with SMTP id 586e51a60fabf-1016409cf0bso1660886fac.12
        for <ell@lists.linux.dev>; Tue, 14 Jun 2022 08:00:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :cc:references:from:in-reply-to:content-transfer-encoding;
        bh=UFVMX397wh6okz3O0yZPQelUcgS4dhX/pOGBxyekFJ0=;
        b=lIUFCgWr6kzansL6TKLcUjsjok03yU6gzj9RKDlWc1Wjv5s7ffRFOn+7uAm93UvtS5
         u10brBZDGZFdckVbpZJB6PGg3KKlCi1RO6tD9AIALFA49uBiSkOGqezFwAzKKONilIsp
         vfwon8eNUPEqe3Ko4xa9foiveUeEsDZZ/HIfBC+jugfjHhJH6Vcgv0CxB0pR7YXSPnKB
         xZW4CmnD9YNqH/YksF4py2IEYE0BSnU5Yfd0q/WaKEUcSLjH49xfmkVoyMyhcaovQPt0
         BRgWcBjjViksPdM5loytRubxkyLWvrIUU7CPDo/9ivI1r2UBGuVWpv0f+r57xrJQaX2G
         W44g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:cc:references:from:in-reply-to
         :content-transfer-encoding;
        bh=UFVMX397wh6okz3O0yZPQelUcgS4dhX/pOGBxyekFJ0=;
        b=C14kvMkg8/u20vzJ3/9aohvBaMCRAbl7InoZcXnzis9Esfy60DT7DPS69D1avqEglf
         DnXuVsOZCSViQ0YEoyqF2d1emAjEO5+d0h6PoxvH2giO86Kb++Tq2eeUHFTVV9A2WGX2
         W/jtx9cAtGUesapHcK09u4jFmAK7X1j8ojFahk32MNomp/Oh5JptYQSjnNQrqvOQCh4L
         txa3nev4BML9lja3ZQKskFmKDK0kzCuI1FUnLROT2ZX9QO3VLATGnkKnfIl/EClvHZw4
         EYbLqQS5eeosOUyZ+QQPN3jTjtL4OgHGMCrXtZGjlOr6fyc8LA9VVYk/hJbx8l9cmFGZ
         2FNg==
X-Gm-Message-State: AJIora84xBij40w8Q3DcKDqvvtrMernTV3e31xVIGLAuvYrPoCJBBtAI
	GJy567LdUlAB1qocrl0dK6U=
X-Google-Smtp-Source: AGRyM1tklsYgdOtzcPG+8KkYa2UEAHrJOol+CnSn4vEtiq1qLklfbcrc9/Nun0XlUHEvVrFHsfkXIA==
X-Received: by 2002:a05:6870:2309:b0:f2:8e9d:c0e0 with SMTP id w9-20020a056870230900b000f28e9dc0e0mr2621391oao.55.1655218803408;
        Tue, 14 Jun 2022 08:00:03 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id a23-20020a4ad5d7000000b0041b703a6131sm5093566oot.45.2022.06.14.08.00.02
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 14 Jun 2022 08:00:02 -0700 (PDT)
Message-ID: <b448db72-549e-f748-3851-9d297b7ea05d@gmail.com>
Date: Tue, 14 Jun 2022 09:48:50 -0500
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.3.0
Subject: Re: Sending and Receiving DBUS Message
Content-Language: en-US
To: Ryan McClue <re.mcclue@protonmail.com>
Cc: "ell@lists.linux.dev" <ell@lists.linux.dev>
References: <VVBTpWPl9dQKNCUMJDgYOFMFEgO_VdFuJ60Eu9ZBWznwRfuoIDDnwp17yk8Et0hiD0NaBFbhi5c1qAM0a-sgP85vbvnk17x_1U_efI5rSLM=@protonmail.com>
 <f6c025d3-a2e8-9f53-8b5b-71703be4c2f6@gmail.com>
 <PyTvMi1te-mCaRAe18nuXlJoIfYvu3xK9CP4XDweGT28egcFExPPkellIjOWwQXzxEbT3qH-KPmokmIcTaAq7UL4FIDs5jWEgA8yW676FTo=@protonmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <PyTvMi1te-mCaRAe18nuXlJoIfYvu3xK9CP4XDweGT28egcFExPPkellIjOWwQXzxEbT3qH-KPmokmIcTaAq7UL4FIDs5jWEgA8yW676FTo=@protonmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Ryan,

<snip>

>    struct l_dbus_message *msg = l_dbus_message_new_method_call(conn, "org.bluez", "/org/bluez/hci0",
>                                                                "org.bluez.Adapter1", "StartDiscovery");
> 
>    l_dbus_send_with_reply(conn, msg, start_discovery_callback, NULL, NULL);
> 
>    l_dbus_message_unref(msg);
> 

l_dbus_send* take ownership of the message, so it is wrong to unref it here.

Regards,
-Denis
