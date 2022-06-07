Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACA5A28FB
	for <ell@lists.linux.dev>; Tue,  7 Jun 2022 15:12:04 +0000 (UTC)
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-f2a4c51c45so23508338fac.9
        for <ell@lists.linux.dev>; Tue, 07 Jun 2022 08:12:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=message-id:date:mime-version:user-agent:subject:content-language:to
         :references:from:in-reply-to:content-transfer-encoding;
        bh=wIweEuGlvg3ExJRWS8Mq/yTQzBfejbOi8h5LAyxK/b8=;
        b=ZMoyKeOaUQzF17sulCntFu5Efu4Di4qaz1lf5wdrhWtcpjVZxYX1lxnJgG3zrLF+j6
         FVzlUielFZlhHN1KUNeKKVMVJZ3p/+YK3h/JG7lOxQFUj7Y4UY5hnPMLTXp9LAQaN9uS
         AcU73GfYf1tuwUupsIfZD7JYN5M3IzVbFMU36dYcEQmHkjTKJPA3Cs4dFT8sCmoXQpjj
         nZbZVRnoJ2cb7tG8ODCz9mfW3TndsRjcQLlZSNNWWOwoGP3gyUXE/hTeFPDnMxRJnx2D
         gd7hrqqe2b7YXzvsaC59lMGq5bZ8WxYe8jYroUOgmdf5gpzshSBS95u1tFPdmbZRBn6k
         haOQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:message-id:date:mime-version:user-agent:subject
         :content-language:to:references:from:in-reply-to
         :content-transfer-encoding;
        bh=wIweEuGlvg3ExJRWS8Mq/yTQzBfejbOi8h5LAyxK/b8=;
        b=tqRf7c2IehI90oVuG+F5Ztb301CrMMjft30LFQQrPZCF7PJ3Bvk2jjMsB/KR7fshTn
         5DpSIBLJ9frBAqNMyUpKAuzstFsUW2NPC0/PHIx0vjXL3PO6rilBj7bfBa7ruUsRuhUq
         vAoMHVARwMXv68TNXBYSQb+TJrf01O4M7VikrMO7WDKJvN8oFz+75jr3IYnrIR7f+D7L
         xfA8+e+kwJ1hfSxb/c0eP2pRXzf3ErI2QbvyBqk3kId0LJXvarhP0zG/+scjxpTQQMY4
         ek0mdqyVE910FZFd4VopjFSZl3CgXhIeuGbHsmCAbc+R/NZBpz+cHOjBXEo7ufCI3ohC
         xkBg==
X-Gm-Message-State: AOAM530Gl/buo7ckbneqGhVHb/hGhVOwkdjYS8TgqrfZk8wTbkbI37/T
	tpeJCuk/TcrfvpVA020pGYvE6GQAkuXj8E/f
X-Google-Smtp-Source: ABdhPJzaLFGbT4zVmI59kxzi4tQ90RwSLmOa1si/Qankd7x2ZDrsF9khMyoDXYwwnA49SQenmvNSxQ==
X-Received: by 2002:a05:6870:e986:b0:f2:4cf7:ddec with SMTP id r6-20020a056870e98600b000f24cf7ddecmr34512472oao.25.1654614723513;
        Tue, 07 Jun 2022 08:12:03 -0700 (PDT)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id t9-20020a056870600900b000f5f4ad194bsm8213022oaa.25.2022.06.07.08.12.02
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 07 Jun 2022 08:12:02 -0700 (PDT)
Message-ID: <f6c025d3-a2e8-9f53-8b5b-71703be4c2f6@gmail.com>
Date: Tue, 7 Jun 2022 10:07:54 -0500
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
To: Ryan McClue <re.mcclue@protonmail.com>,
 "ell@lists.linux.dev" <ell@lists.linux.dev>
References: <VVBTpWPl9dQKNCUMJDgYOFMFEgO_VdFuJ60Eu9ZBWznwRfuoIDDnwp17yk8Et0hiD0NaBFbhi5c1qAM0a-sgP85vbvnk17x_1U_efI5rSLM=@protonmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <VVBTpWPl9dQKNCUMJDgYOFMFEgO_VdFuJ60Eu9ZBWznwRfuoIDDnwp17yk8Et0hiD0NaBFbhi5c1qAM0a-sgP85vbvnk17x_1U_efI5rSLM=@protonmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Ryan,

On 6/7/22 06:05, Ryan McClue wrote:
> Upon examining 'examples/dbus-client.c', it does not seem to contain DBUS message sending and receiving/parsing.

Hmm.. this particular example exercises the l_dbus_client/l_dbus_proxy API . 
These take care of parsing DBus.Properties messages for you.  It should be very 
easily adapted to what you need.

You can also take a peek at the dbus unit tests in unit/ which exercise the dbus 
API in various ways, including message parsing. 'unit/test-dbus-message.c' might 
have what you want.

> As a simple example, I want to call the "Get()" method with arguments "org.freedesktop.hostname1" and "Hostname". This method is of the interface "org.freedesktop.DBus.Properties". I want to parse the return of this method call to get the hostname of my machine.

If the interface implements DBus.Properties properly, then you really do not 
need to invoke the .Get() method directly.  l_dbus_proxy_get_property() should 
be all you need.

But if you still want to:

> Take my example code (with error handling omitted):
> 
> l_main_init();
> 
> struct l_dbus *conn = l_dbus_new_default(L_DBUS_SYSTEM_BUS);
> const char *service = "org.freedesktop.hostname1";
> const char *object = "/org/freedesktop/hostname1";
> const char *interface = "org.freedesktop.DBus.Properties";
> const char *method = "Get";
> 
> struct l_dbus_message *msg = l_dbus_message_new_method_call(conn, service, object, interface, method);
> const char *get_interface = "org.freedesktop.hostname1";
> const char *get_property = "Hostname";
> l_dbus_message_set_arguments(msg, "ss", get_interface, get_property);


So far this looks fine.  You need to invoke l_dbus_send_with_reply() to send the 
message and register a callback for the reply.

> 
> ///////////////////////////////////
> // How to send and parse output????
> ///////////////////////////////////

Something like:

l_dbus_send_with_reply(dbus_conn, msg, get_hostname_cb, NULL, NULL);

> 
> l_dbus_destroy(dbus_conn);
> l_main_exit();
> 

Note that the main event loop must be running until you receive the reply, so 
you need l_main_run...() somewhere and only perform these two steps after the 
main loop has exited.

ell is a purely event-loop driven API, so we have no blocking version of 
l_dbus_send() unlike other D-Bus binding libraries.

> 

static void get_hostname_cb(struct l_dbus_message *reply, void *user_data)
{
	struct l_dbus_message_iter iter;
	const char *hostname;

	l_dbus_message_get_arguments(reply, "v", &iter);

	l_dbus_message_iter_get_variant(&iter, "s", &hostname);
}

> Could someone please fill in the blanks for me?
> Thanks
> 
> --
> Ryan McClue, Sydney
> 

Hope this helps.

Regards,
-Denis
