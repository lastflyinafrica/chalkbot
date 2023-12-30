# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 


resource "aws_connect_instance" "chalkbot_connect" {
  instance_alias = "chalkbot-kampus-connect"

  auto_resolve_best_voices_enabled = true
  contact_flow_logs_enabled        = true
  contact_lens_enabled             = false
  identity_management_type         = "CONNECT_MANAGED"
  early_media_enabled              = false
  inbound_calls_enabled            = true
  outbound_calls_enabled           = false
  multi_party_conference_enabled   = false
}

resource "aws_connect_phone_number" "uk_phone_number" {
  target_arn   = aws_connect_instance.chalkbot_connect.arn
  type         = "DID"
  country_code = "GB"
}

resource "aws_connect_contact_flow" "gpt_contact_flow" {
  instance_id = aws_connect_instance.chalkbot_connect.id
  name        = "GPT Flow"
  description = "Contact flow that will be used for GPT conversation"
  type        = "CONTACT_FLOW"
  # This can be obtained either by going into the console and exporting the contact flow
  # or equally can run:
  #   aws connect describe-contact-flow --instance-id <value> --contact-flow-id <value> | jq '.ContactFlow.Content | fromjson' > contact_flow.json
  content = templatefile("${path.module}/gpt-contact-flow.json", {
    lex_bot_alias_name                = "ChalkbotLexVersion1Alias"
    lex_alias_arn                     = var.lex_alias_arn
    lex_bot_name                      = "ChalkbotLexBot"
    connect_authentication_lambda_arn = var.connect_authentication_lambda_arn
    gpt_lambda_arn                    = var.gpt_lambda_arn
  })
  content_hash = filebase64sha256("${path.module}/gpt-contact-flow.json")
}

resource "aws_connect_security_profile" "admin_security_profile" {
  instance_id = aws_connect_instance.chalkbot_connect.id
  name        = "Chalkbot Admin"
  permissions = jsondecode(file("${path.module}/admin-permissions.json"))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_connect_queue" "connect_queue" {
  instance_id = aws_connect_instance.chalkbot_connect.id
  # cut instance id from prefix
  hours_of_operation_id = split(":", "${aws_connect_hours_of_operation.connect_hours.id}")[1]

  name = "Standard Queue"

  depends_on = [aws_connect_hours_of_operation.connect_hours]
}

resource "aws_connect_routing_profile" "basic_routing_profile" {
  instance_id = aws_connect_instance.chalkbot_connect.id
  # cut connect instance id from the prefix
  default_outbound_queue_id = split(":", "${aws_connect_queue.connect_queue.id}")[1]

  name        = "Standard Routing Profile"
  description = "A simple routing profile"

  media_concurrencies {
    channel     = "VOICE"
    concurrency = 1
  }

  queue_configs {
    channel  = "VOICE"
    delay    = 1
    priority = 1
    queue_id = split(":", "${aws_connect_queue.connect_queue.id}")[1]
  }
}

resource "aws_connect_user" "connect_user" {
  instance_id = aws_connect_instance.chalkbot_connect.id
  name        = "chalkbot-admin"
  password    = var.connect_user_password

  phone_config {
    after_contact_work_time_limit = 0
    phone_type                    = "SOFT_PHONE"
  }

  identity_info {
    first_name = "Aidan"
    last_name  = "Jakes"
  }

  # cut connect instance id from the prefix
  routing_profile_id   = split(":", "${aws_connect_routing_profile.basic_routing_profile.id}")[1]
  security_profile_ids = [split(":", "${aws_connect_security_profile.admin_security_profile.id}")[1]]
}

# allow connect to call authentication lambda
resource "aws_connect_lambda_function_association" "authentication_lambda" {
  instance_id  = aws_connect_instance.chalkbot_connect.id
  function_arn = var.connect_authentication_lambda_arn
}

resource "aws_lambda_permission" "authentication_lambda" {
  statement_id  = "AllowExecutionFromConnect"
  action        = "lambda:InvokeFunction"
  function_name = var.connect_authentication_lambda_name
  principal     = "connect.amazonaws.com"
  source_arn    = aws_connect_instance.chalkbot_connect.arn
}

# allow connect to call gpt lambda
resource "aws_connect_lambda_function_association" "gpt_lambda" {
  instance_id  = aws_connect_instance.chalkbot_connect.id
  function_arn = var.gpt_lambda_arn
}

resource "aws_lambda_permission" "gpt_lambda" {
  statement_id  = "AllowExecutionFromConnect"
  action        = "lambda:InvokeFunction"
  function_name = var.gpt_lambda_name
  principal     = "connect.amazonaws.com"
  source_arn    = aws_connect_instance.chalkbot_connect.arn
}

resource "aws_connect_hours_of_operation" "connect_hours" {
  instance_id = aws_connect_instance.chalkbot_connect.id
  name        = "All Hours"
  time_zone   = "UTC"

  config {
    day = "MONDAY"
    start_time {
      hours   = 0
      minutes = 0
    }
    end_time {
      hours   = 0
      minutes = 0
    }
  }
  config {
    day = "TUESDAY"
    start_time {
      hours   = 0
      minutes = 0
    }
    end_time {
      hours   = 0
      minutes = 0
    }
  }
  config {
    day = "WEDNESDAY"
    start_time {
      hours   = 0
      minutes = 0
    }
    end_time {
      hours   = 0
      minutes = 0
    }
  }
  config {
    day = "THURSDAY"
    start_time {
      hours   = 0
      minutes = 0
    }
    end_time {
      hours   = 0
      minutes = 0
    }
  }
  config {
    day = "FRIDAY"
    start_time {
      hours   = 0
      minutes = 0
    }
    end_time {
      hours   = 0
      minutes = 0
    }
  }
  config {
    day = "SATURDAY"
    start_time {
      hours   = 0
      minutes = 0
    }
    end_time {
      hours   = 0
      minutes = 0
    }
  }
  config {
    day = "SUNDAY"
    start_time {
      hours   = 0
      minutes = 0
    }
    end_time {
      hours   = 0
      minutes = 0
    }
  }
}
