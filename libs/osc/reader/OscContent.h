/*
 * Copyright (c) 2014 MUGEN SAS
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef OSC_CONTENT_H_
#define OSC_CONTENT_H_

#include <QtCore/QtGlobal>
#include <QtCore/QVector>
#include <osc/OscAPI.h>

class OscBundle;
class OscMessage;
class ByteBuffer;

/**
 * Abstract class to manage packet embedded content as objects.
 */
class OSC_API OscContent
{

public:

    enum Type {
        Bundle,
        Message
    };

    virtual ~OscContent();

    ByteBuffer* getPacket();
    Type getType();
    void setType(Type t);

protected:
    qint32 mDataIdx;
    qint32 mStartIdx;
    ByteBuffer* mPacket;
    Type mType;

    /** Build the current OscContent object. */
    OscContent(ByteBuffer* packet);
};

#endif // OSC_CONTENT_H_
