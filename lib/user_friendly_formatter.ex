#
# This file is part of PrettyLog.
#
# Copyright 2019-2021 Ispirata Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule PrettyLog.UserFriendlyFormatter do
  alias Logger.Formatter
  alias PrettyLog.TextSanitizer

  epoch = {{1970, 1, 1}, {0, 0, 0}}
  @epoch :calendar.datetime_to_gregorian_seconds(epoch)

  def format(level, message, timestamp, metadata) do
    {date, {h, m, s, millis}} = timestamp

    pre_message_metadata = Application.get_env(:logfmt, :prepend_metadata, [])

    {pre_meta, metadata} = Keyword.split(metadata, pre_message_metadata)

    timestamp =
      :erlang.localtime_to_universaltime({date, {h, m, s}})
      |> :calendar.datetime_to_gregorian_seconds()
      |> Kernel.-(@epoch)

    timestamp_string =
      (timestamp * 1000 + millis)
      |> :calendar.system_time_to_rfc3339(unit: :millisecond)
      |> to_string()

    level_string =
      level
      |> TextSanitizer.sanitize()
      |> String.upcase()
      |> String.pad_trailing(5)

    sanitized_message =
      message
      |> TextSanitizer.sanitize()
      |> :erlang.iolist_to_binary()
      |> Formatter.prune()

    encoded_metadata =
      (pre_meta ++ metadata)
      |> TextSanitizer.sanitize_keyword()
      |> Logfmt.encode(output: :iolist)

    if encoded_metadata != [] do
      [timestamp_string, "\t|", level_string, "| ", sanitized_message, "  ", encoded_metadata, ?\n]
    else
      [timestamp_string, "\t|", level_string, "| ", sanitized_message, ?\n]
    end
  rescue
    _ -> "LOG_FORMATTER_ERROR: #{inspect({level, message, timestamp, metadata})}\n"
  end
end
