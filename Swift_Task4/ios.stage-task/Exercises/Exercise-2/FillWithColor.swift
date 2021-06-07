import Foundation

final class FillWithColor {
    
    func fillWithColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int) -> [[Int]] {
        
        var numToFill: Int?
        
        for (rIndex, r) in image.enumerated() {
            if (rIndex == row) {
                for (cIndex, _) in r.enumerated() {
                    if (cIndex == column) {
                        numToFill = image[rIndex][cIndex];
                        break;
                    }
                }
            }
        }
        
        if (numToFill == nil) {
            return image;
        }
        
        var result = image;
        
        for rIndex in 0..<image.count {
            let r = image[rIndex];
            var shouldProcessRow = true;
            
            if (
                rIndex - 1 >= 0 &&
                image[rIndex - 1][column] != numToFill!
            ) {
                shouldProcessRow = false;
            }
            
            for cIndex in 0..<r.count {
                if (cIndex == column && shouldProcessRow) {
                    var tempCIndex = cIndex;
                    
                    while(
                        tempCIndex < image[rIndex].count &&
                        image[rIndex][tempCIndex] == numToFill!
                    ) {
                        result[rIndex][tempCIndex] = newColor;
                        tempCIndex += 1;
                    }
                    
                    tempCIndex = cIndex;
                    while(
                        tempCIndex >= 0 &&
                        image[rIndex][tempCIndex] == numToFill!
                    ) {
                        result[rIndex][tempCIndex] = newColor;
                        tempCIndex -= 1;
                    }
                }
            }
        }
        
        return result;
    }
}
