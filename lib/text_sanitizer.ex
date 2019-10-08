#
# This file is part of Astarte.
#
# Copyright 2019 Ispirata Srl
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

defmodule PrettyLog.TextSanitizer do
  alias Logger.Formatter

  def sanitize_keyword(keywords) do
    Enum.map(keywords, fn {k, v} ->
      {k, sanitize(v)}
    end)
  end

  def sanitize(value) when is_atom(value) do
    Atom.to_string(value)
  end

  def sanitize(value) when is_binary(value) do
    Formatter.prune(value)
  end

  def sanitize(value) when is_list(value) do
    value
    |> Formatter.prune()
    |> :erlang.iolist_to_binary()
  rescue
    _ ->
      value
      |> :erlang.term_to_binary()
      |> Base.encode64()
  end

  def sanitize(value) do
    value
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end
end