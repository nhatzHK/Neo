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

#ifndef OSC_READER_H_
#define OSC_READER_H_

#include <osc/OscVersion.h>
#include <QtCore/QByteArray>
#include <osc/reader/OscContent.h>

class ByteBuffer;
class OscBundle;
class OscMessage;
class OscContent;

class OSC_API OscReader
{
public:
    /**
     * @brief Conversion type for current OscContent object as an OscBundle object.
     *
     * @return this as an OscBundle object. If this cannot be convert to an
     *         OscBundle object, returns null.
     */
    OscBundle* getBundle();

    /**
     * @brief Conversion type for current OscContent object as an OscMessage
     * object.
     *
     * @return this as an OscMessage object. If this cannot be convert to an
     *         OscMessage object, returns null.
     */
    OscMessage* getMessage();

    OscContent::Type getContentType();

    /**
     * @brief Build a new OscContent object based on the passed byte buffer.
     *
     * @param src
     *            the byte buffer to parse containing OSC messages
     * @throws ReadMessageException
     *             The contained message cannot be read properly.
     */
    OscReader(QByteArray* src);

    /**
     * @brief Build a new OscContent object based on the passed byte buffer.
     *
     * @param src
     *            the byte buffer to parse containing OSC messages
     * @param offset
     *            the position where to start reading the byte buffer
     * @param size
     *            the size of the byte buffer
     * @throws ReadMessageException
     *             The contained message cannot be read properly.
     */
    OscReader(QByteArray* src, qint32 offset, qint32 size);

    /**
     * @brief Destructor.
     */
    ~OscReader();

private:

    OscContent* mContent;
    ByteBuffer* mPacket;
    qint32 mPacketSize;

    void init(QByteArray* src, qint32 offset, qint32 size);

    friend class OscMessage;
};

#endif // OSC_READER_H_
