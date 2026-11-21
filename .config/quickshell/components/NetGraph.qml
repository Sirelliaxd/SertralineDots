import QtQuick
import "root:/"

Canvas {
    id: root

    property var samples: []

    onSamplesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        ctx.strokeStyle = Theme.networkDropdownGraphGridColor;
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(0, height - 0.5);
        ctx.lineTo(width, height - 0.5);
        ctx.stroke();

        if (samples.length < 2)
            return;

        var max = 0;
        for (var i = 0; i < samples.length; i++)
            max = Math.max(max, samples[i].rx, samples[i].tx);
        if (max <= 0)
            return;

        root.drawSeries(ctx, "rx", Theme.networkDropdownGraphRxColor, max);
        root.drawSeries(ctx, "tx", Theme.networkDropdownGraphTxColor, max);
    }

    function drawSeries(ctx, key, color, max) {
        ctx.strokeStyle = color;
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        for (var i = 0; i < samples.length; i++) {
            var x = i / (samples.length - 1) * width;
            var y = height - (samples[i][key] / max) * (height - 2) - 1;
            if (i === 0)
                ctx.moveTo(x, y);
            else
                ctx.lineTo(x, y);
        }
        ctx.stroke();
    }
}
