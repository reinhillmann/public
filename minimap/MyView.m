#import "MyView.h"

@interface MyView() {
    NSPoint mouseLocation;
    CGFloat ellipseRadiusX;
    CGFloat ellipseRadiusY;
}
@end

@implementation MyView

- (void)awakeFromNib {
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds] options:options owner:self userInfo:nil];
    [self addTrackingArea:area];

    ellipseRadiusX = 100.0;
    ellipseRadiusY = 80.0;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSPoint mid = NSMakePoint(self.bounds.size.width / 2, self.bounds.size.height / 2);
    [self drawEllipseAtMidpoint:mid withRadius:NSMakeSize(ellipseRadiusX, ellipseRadiusY)];
    
    BOOL inside = YES;
    NSPoint p = mouseLocation;
    if (![self point:mouseLocation isInsideEllipseWithRadiusX:ellipseRadiusX radiusY:ellipseRadiusY atMidPoint:mid]) {
        p = [self lineIntersectionFromPoint:mouseLocation withEllipseRadiusX:ellipseRadiusX radiusY:ellipseRadiusY atMidPoint:mid];
        inside = NO;
    }
    
    [[NSColor blackColor] set];
    NSBezierPath *marker = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(p.x - 5, p.y - 5, 10, 10)];
    if (inside) {
        [marker stroke];
    } else {
        [marker fill];
    }
}

- (void)drawEllipseAtMidpoint:(NSPoint)point withRadius:(NSSize)radius {
    NSSize s = NSMakeSize(radius.width * 2, radius.height * 2);
    NSPoint p = NSMakePoint(point.x - (s.width / 2), point.y - (s.height / 2));
    NSRect rect = NSMakeRect(p.x, p.y, s.width, s.height);
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
    [[NSColor whiteColor] set];
    [path fill];
    [[NSColor redColor] set];
    [path stroke];
}


- (NSPoint)lineIntersectionFromPoint:(NSPoint)p1 withEllipseRadiusX:(CGFloat)radiusX radiusY:(CGFloat)radiusY atMidPoint:(NSPoint)mid {
    // http://mathworld.wolfram.com/Ellipse-LineIntersection.html
    // Normalize the point to the origin
    NSPoint p2 = NSMakePoint(p1.x - mid.x, p1.y - mid.y);
    CGFloat r = ((radiusX * radiusY) / sqrt((radiusX * radiusX * p2.y * p2.y) + (radiusY * radiusY * p2.x * p2.x)));
    CGFloat x = r * p2.x;
    CGFloat y = r * p2.y;
    return NSMakePoint(x + mid.x, y + mid.y);
}

- (BOOL)point:(NSPoint)p1 isInsideEllipseWithRadiusX:(CGFloat)radiusX radiusY:(CGFloat)radiusY atMidPoint:(NSPoint)mid {
    // http://math.stackexchange.com/questions/76457/check-if-a-point-is-within-an-ellipse
    // Normalize the point to the origin
    NSPoint p2 = NSMakePoint(p1.x - mid.x, p1.y - mid.y);
    // A fast bounding box check:
    if (p2.x > radiusX || p2.x < -radiusX || p2.y > radiusY || p2.y < -radiusY) return NO;
    // Now check the slower way:
    return ((p2.x * p2.x) / (radiusX * radiusX)) + ((p2.y * p2.y) / (radiusY * radiusY)) < 1;
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    mouseLocation = [theEvent locationInWindow];
    [self setNeedsDisplay:YES];
}

@end
