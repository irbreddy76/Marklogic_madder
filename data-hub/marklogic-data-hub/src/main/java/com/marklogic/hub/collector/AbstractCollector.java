/*
 * Copyright 2012-2016 MarkLogic Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.marklogic.hub.collector;

import java.util.List;

import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import com.marklogic.hub.plugin.PluginType;

public abstract class AbstractCollector implements Collector {

    private PluginType type;

    public AbstractCollector(PluginType type) {
        this.type = type;
    }

    @Override
    public PluginType getType() {
        return this.type;
    }

    @Override
    public abstract List<String> run();

    @Override
    public abstract void serialize(XMLStreamWriter serializer) throws XMLStreamException;
}
