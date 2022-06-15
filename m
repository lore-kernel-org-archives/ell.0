Received: from mail-oi1-f179.google.com (mail-oi1-f179.google.com [209.85.167.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D61B1FA4
	for <ell@lists.linux.dev>; Wed, 15 Jun 2022 03:59:39 +0000 (UTC)
Received: by mail-oi1-f179.google.com with SMTP id q11so13993683oih.10
        for <ell@lists.linux.dev>; Tue, 14 Jun 2022 20:59:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :cc:references:from:in-reply-to:content-transfer-encoding;
        bh=GST9Vz5rEiCj75uzAlHrnyqAY7HNWtNQB44wpW3nTUs=;
        b=n7PFdYzdlkB7ifJOON2oKWRnkA8reys7CVVrXaQTfyoo81rnuB5Xoq8HhjFcYtLiW4
         SoAHsFCFbRCT0DUFst35HLfi6olaiiDGr1mD7S67dPnp0LoKfQazeeRLSHmEm3fsWW6b
         /I8OIpEnX4XJsRogD752zS2uptRcSMT/KMZnLxRs46jM0PkgdB+HHLTAunNDD0qiqu/g
         Z2iIkTO5G52KkbnS+wVBWi5uBfBSydK+tehUtV3062nLyrDWKDGCRG/oy+kEffztjWiu
         sJoMGgmzn2AFJsXdZQhXAI4lSHmscHd6IrzkRiOVFkCwU9V0NWSoAEXMGnuZEWStia1e
         zpLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:cc:references:from:in-reply-to
         :content-transfer-encoding;
        bh=GST9Vz5rEiCj75uzAlHrnyqAY7HNWtNQB44wpW3nTUs=;
        b=49A9e2zdI1EXR3AyOA3PnRZ4Yp65ddpr6b3ScHRK92pY6IEftj7qUoLH3gsFFgtImx
         z6x5uakB0adOcKeTK8dBJqt8g0rXA1d+0WSsLLAAEyQ6nyFQqgrBhMnJHKTJLDVCGTL3
         DuSLG3OPGkR/PCobDJpTpG2aeOFLv0S8Wd+BRGjLRYsBo0EXAtmzHG4YHttn42uhHVxU
         tGuSwKIZcdOdG/c/3Nn9v8tzdvyQY7GZ2ziq86Br/tYrD/WYt3wiYN2xfWLuItW6M0ex
         zP0cVjb3pM7P/vDZt1J0xwGVTfQ1XPzN/ui45raN+6d5zm+M45URyVTtxuDLTUZfTeZR
         0vxw==
X-Gm-Message-State: AOAM533bvXMx6Mx1vvDuofmCtV5Ji5FzEd9+i7eJDdBijkNqsZ6tQkV4
	xQ40SDsrfwQdqAzuOvd4v6c=
X-Google-Smtp-Source: ABdhPJxgvlFzolXuEi1c5cnQdgazpm0hLSaOAjN5rjbpIkW/oSGNZbTVja1zsiOle1bxx/e9lqCT8Q==
X-Received: by 2002:a05:6808:1905:b0:32e:c7f6:b75c with SMTP id bf5-20020a056808190500b0032ec7f6b75cmr3988545oib.247.1655265578559;
        Tue, 14 Jun 2022 20:59:38 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id a23-20020a4ad5d7000000b0041b703a6131sm5915490oot.45.2022.06.14.20.59.37
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 14 Jun 2022 20:59:38 -0700 (PDT)
Message-ID: <603b4d33-aa7b-1974-f41b-d9930d5f0eba@gmail.com>
Date: Tue, 14 Jun 2022 22:53:09 -0500
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
 <b448db72-549e-f748-3851-9d297b7ea05d@gmail.com>
 <wk-twE8P7fmAykCAdLvcaPGWWzSscceUiLEpbWSuUV1-uQWzsrMcDyNszaOKEMiPRWLhATf11gMgyp9VUcGXPVkkFFzeTOnLhSN9CX9G1x8=@protonmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <wk-twE8P7fmAykCAdLvcaPGWWzSscceUiLEpbWSuUV1-uQWzsrMcDyNszaOKEMiPRWLhATf11gMgyp9VUcGXPVkkFFzeTOnLhSN9CX9G1x8=@protonmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Ryan,

>>> struct l_dbus_message *msg = l_dbus_message_new_method_call(conn, "org.bluez", "/org/bluez/hci0",
>>> "org.bluez.Adapter1", "StartDiscovery");
>>>

You also need to make sure to set the arguments on the message.  In your case:

l_dbus_message_set_arguments(msg, "");

We probably should have l_dbus_send* reject messages which have not been setup 
properly.  But since you're not checking the error, it wouldn't really help :)

>>> l_dbus_send_with_reply(conn, msg, start_discovery_callback, NULL, NULL);
>>>
>>> l_dbus_message_unref(msg);

Here's a functional example based on your code.

http://dpaste.com/8GVMYE3DY

Regards,
-Denis
